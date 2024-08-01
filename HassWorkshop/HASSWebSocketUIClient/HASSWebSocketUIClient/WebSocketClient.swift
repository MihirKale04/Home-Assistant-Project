//
//  WebSocketClient.swift
//  HASSWebSocketUIClient
//
//  Created by Mihir Kale on 6/20/24.
//

import Foundation
import SwiftUI

enum WebSocketError: String {
    case websocketNotRunning = "WebSocket not running"
    case authError = "Authentication error"
    case connectionFailed = "Connection failed"
    case connectionSuccessful = "Connection successful"
}

class WebSocketClient: NSObject, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    var url: URL
    var accessToken: String
    private var messageId: Int
    private var reconnectionTimer: Timer?
    
    @Published var isConnected: Bool = false
    @Published var connectionMessage: String?
    @Published var alarmState: String = "Unknown"
    
    
    
    init(url: URL, accessToken: String) {
        self.url = url
        self.accessToken = accessToken
        self.messageId = 1
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }
    
    func connect() {
        self.webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        print("Connecting to WebSocket...")
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        DispatchQueue.main.async {
            self.connectionMessage = nil
        }
        print("Disconnected from WebSocket")
    }
    
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            } else {
                print("Message sent: \(message)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
                self?.handleError(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleMessage(text)
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    fatalError("Received unknown message type")
                }
                
                self?.receiveMessage() // Continue to receive more messages
            }
        }
    }
    
    private func handleMessage(_ message: String) {
        if let data = message.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let type = json["type"] as? String {
                        switch type {
                        case "auth_required":
                            sendAuthMessage()
                        case "auth_ok":
                            DispatchQueue.main.async {
                                self.isConnected = true
                                self.connectionMessage = WebSocketError.connectionSuccessful.rawValue
                                self.stopReconnectionAttempts()
                            }
                            sendGetStatesMessage()
                            sendSubscribeEventsMessage()
                        case "auth_invalid":
                            DispatchQueue.main.async {
                                self.isConnected = false
                                self.connectionMessage = WebSocketError.authError.rawValue
                            }
                        case "result":
                            if let result = json["result"] as? [[String: Any]] {
                                self.handleGetStatesResult(result)
                            }
                        case "event":
                            if let event = json["event"] as? [String: Any] {
                                self.handleStateChangedEvent(event)
                            }
                        default:
                            print("Received message: \(json)")
                        }
                    }
                }
            } catch {
                print("Failed to decode JSON message: \(error)")
            }
        }
    }
    
    private func sendAuthMessage() {
        let authMessage: [String: Any] = ["type": "auth", "access_token": accessToken]
        if let jsonData = try? JSONSerialization.data(withJSONObject: authMessage, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sendMessage(jsonString)
        }
    }
    
    private func sendGetStatesMessage() {
        let getStatesMessage: [String: Any] = [
            "id": messageId,
            "type": "get_states"
        ]
        sendJSONMessage(getStatesMessage)
        messageId += 1
    }
    
    private func sendSubscribeEventsMessage() {
            let subscribeEventsMessage: [String: Any] = [
                "id": messageId,
                "type": "subscribe_events",
                "event_type": "state_changed"
            ]
            sendJSONMessage(subscribeEventsMessage)
            messageId += 1
        }
    
    
    func armAlarm() {
        let armAlarmMessage: [String: Any] = [
            "id": messageId,
            "type": "call_service",
            "domain": "alarmo",
            "service": "arm",
            "service_data": ["entity_id": "alarm_control_panel.alarmo"]
        ]
        sendJSONMessage(armAlarmMessage)
        messageId += 1
    }
    
    func disarmAlarm(code: String) {
        let disarmAlarmMessage: [String: Any] = [
            "id": messageId,
            "type": "call_service",
            "domain": "alarmo",
            "service": "disarm",
            "service_data": ["entity_id": "alarm_control_panel.alarmo", "code": code]
        ]
        sendJSONMessage(disarmAlarmMessage)
        messageId += 1
    }
    
    private func sendJSONMessage(_ message: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            sendMessage(jsonString)
        }
    }
    
    private func handleGetStatesResult(_ result: [[String: Any]]) {
        for entity in result {
            if let entityId = entity["entity_id"] as? String, entityId == "alarm_control_panel.alarmo" {
                if let state = entity["state"] as? String {
                    DispatchQueue.main.async {
                        self.alarmState = state
                    }
                }
                break
            }
        }
    }
    
    private func handleStateChangedEvent(_ event: [String: Any]) {
        if let eventData = event["data"] as? [String: Any],
           let newState = eventData["new_state"] as? [String: Any],
           let entityId = newState["entity_id"] as? String,
           entityId == "alarm_control_panel.alarmo",
           let state = newState["state"] as? String {
            DispatchQueue.main.async {
                self.alarmState = state
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let nsError = error as NSError
        var errorMessage = WebSocketError.connectionFailed.rawValue
        
        if nsError.domain == NSPOSIXErrorDomain && nsError.code == 57 {
            errorMessage = WebSocketError.websocketNotRunning.rawValue
        } else if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
            errorMessage = WebSocketError.websocketNotRunning.rawValue
        }
        
        DispatchQueue.main.async {
            self.connectionMessage = errorMessage
            self.isConnected = false
            self.startReconnectionAttempts()
        }
    }
    
    private func startReconnectionAttempts() {
        stopReconnectionAttempts()
        reconnectionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.connect()
        }
    }
    
    private func stopReconnectionAttempts() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket did connect")
        DispatchQueue.main.async {
            self.connectionMessage = WebSocketError.connectionSuccessful.rawValue
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket did disconnect")
        DispatchQueue.main.async {
            self.connectionMessage = nil
            self.isConnected = false
            self.startReconnectionAttempts()
        }
    }
}


