//
//  WebSocketClient.swift
//  HASSWebSocketUIClient
//
//  Created by Mihir Kale on 6/20/24.
//

import Foundation

enum WebSocketError: String {
    case websocketNotRunning = "WebSocket not running"
    case authError = "Authentication error"
    case connectionFailed = "Connection failed"
    case connectionSuccessful = "Connection successful"
}

class WebSocketClient: NSObject, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let url: URL
    private let accessToken: String
    private var messageId: Int
    
    @Published var isConnected: Bool = false
    @Published var connectionMessage: String?
    
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
                            }
                        case "auth_invalid":
                            DispatchQueue.main.async {
                                self.isConnected = false
                                self.connectionMessage = WebSocketError.authError.rawValue
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
    
    func turnOn() {
        let turnOnMessage: [String: Any] = [
            "id": messageId,
            "type": "call_service",
            "domain": "switch",
            "service": "turn_on",
            "service_data": ["entity_id": "switch.wall_plug_mss110_main_channel"]
        ]
        sendJSONMessage(turnOnMessage)
        messageId += 1
    }
    
    func turnOff() {
        let turnOffMessage: [String: Any] = [
            "id": messageId,
            "type": "call_service",
            "domain": "switch",
            "service": "turn_off",
            "service_data": ["entity_id": "switch.wall_plug_mss110_main_channel"]
        ]
        sendJSONMessage(turnOffMessage)
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
        
        func disarmAlarm() {
            let disarmAlarmMessage: [String: Any] = [
                "id": messageId,
                "type": "call_service",
                "domain": "alarmo",
                "service": "disarm",
                "service_data": ["entity_id": "alarm_control_panel.alarmo", "code": "1234"]
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
        }
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
        }
    }
}

