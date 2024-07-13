//
//  ContentView.swift
//  HASSWebSocketUIClient
//
//  Created by Mihir Kale on 6/20/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webSocketClient = WebSocketClient(
        url: URL(string: "ws://192.168.68.79:8123/api/websocket")!,
        accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxNGI5YzNiZDYxNmE0NDhmYjk1YjNiZWUwZWFlZWU2NiIsImlhdCI6MTcxODc1NTU0NywiZXhwIjoyMDM0MTE1NTQ3fQ.s2k4dEZAJryVZE-BhCWib0yuLR7b-QeyW2t2k5pJ8C8" // Replace with your actual access token
    )
    @State private var showingControlView = false
    @State private var showError = false
    
    var body: some View {
        VStack {
            Spacer()
            
            if webSocketClient.isConnected {
                ControlView(webSocketClient: webSocketClient)
            } else {
                VStack {
                    if showError {
                        Text("Unable to Connect")
                            .padding()
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
            
            Text(webSocketClient.isConnected ? "Connected" : "Disconnected")
                .padding()
                .foregroundColor(webSocketClient.isConnected ? .green : .red)
        }
        .onAppear {
            webSocketClient.connect()
        }
        .onChange(of: webSocketClient.connectionMessage) { message in
            if message == WebSocketError.connectionFailed.rawValue && !webSocketClient.isConnected {
                showError = true
            }
        }
        .padding()
    }
}

struct ControlView: View {
    @ObservedObject var webSocketClient: WebSocketClient
        
    var body: some View {
        VStack {
            Button("Turn On") {
                webSocketClient.turnOn()
            }
            .padding()
            
            Button("Turn Off") {
                webSocketClient.turnOff()
            }
            .padding()
            
            Button("Arm Alarm") {
                webSocketClient.armAlarm()
            }
            .padding()
            
            Button("Disarm Alarm") {
                webSocketClient.disarmAlarm()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
