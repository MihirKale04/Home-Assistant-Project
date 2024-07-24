//
//  ContentView.swift
//  HASSWebSocketUIClient
//
//  Created by Mihir Kale on 6/20/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webSocketClient: WebSocketClient
    @State private var showingControlView = false
    @State private var showError = false
    @State private var showingConfiguration = false
    
    init() {
        let urlString = UserDefaults.standard.string(forKey: "webSocketURL") ?? ""
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        if let url = URL(string: urlString) {
            _webSocketClient = StateObject(wrappedValue: WebSocketClient(url: url, accessToken: accessToken))
        } else {
            _webSocketClient = StateObject(wrappedValue: WebSocketClient(url: URL(string: "ws://default_url")!, accessToken: accessToken))
        }
    }
    
    var body: some View {
        VStack {
        
            HStack {
                Spacer()
                Button(action: {
                    showingConfiguration = true
                }) {
                    Text("Configure")
                        .padding(3)
                        .background(Color(.darkGray))
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }
                .padding([.top], 40)
                Spacer()
            }
            
            Spacer()
            
            if webSocketClient.isConnected {
                ControlView(webSocketClient: webSocketClient)
            } else {
                VStack {
                    if showError {
                        Text("No Connection")
                            .padding(10)
                            //z`.background(Color(red: 0.2, green: 0.0, blue: 0.0))
                            .font(.title3)
                            .foregroundColor(.red)
                            .cornerRadius(5)
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
        .sheet(isPresented: $showingConfiguration) {
            ConfigurationView(onSave: {
                reconnectWebSocketClient()
            })
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.2, green: 0.2, blue: 0.2)) // Set background color
        .edgesIgnoringSafeArea(.all) // Extend background color to safe area
    }
    
    private func reconnectWebSocketClient() {
        let urlString = UserDefaults.standard.string(forKey: "webSocketURL") ?? ""
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        if let url = URL(string: urlString) {
            webSocketClient.disconnect()
            webSocketClient.url = url
            webSocketClient.accessToken = accessToken
            webSocketClient.connect()
        }
    }
}

struct ControlView: View {
    @ObservedObject var webSocketClient: WebSocketClient
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Arm Alarm") {
                webSocketClient.armAlarm()
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .foregroundColor(.white)
            .background(Color(red: 0.3, green: 0.1,  blue: 0.1))
            .cornerRadius(30)
            .shadow(radius: 10)
            .font(.largeTitle)
            .bold()
            
            Button("Disarm Alarm") {
                webSocketClient.disarmAlarm()
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .foregroundColor(.white)
            .background(Color(red: 0.1, green: 0.1,  blue: 0.2))
            .cornerRadius(30)
            .shadow(radius: 10)
            .font(.largeTitle)
            .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
