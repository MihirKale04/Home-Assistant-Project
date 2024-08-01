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
        let IPAddress = UserDefaults.standard.string(forKey: "IPAddress") ?? ""
        let port = UserDefaults.standard.string(forKey: "port") ?? ""
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        if let url = URL(string: "ws://\(IPAddress):\(port)/api/websocket") {
            print(url)
            _webSocketClient = StateObject(wrappedValue: WebSocketClient(url: url, accessToken: accessToken))
        } else {
            _webSocketClient = StateObject(wrappedValue: WebSocketClient(url: URL(string: "ws://192.168.68.79:8123/api/poop")!, accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxNGI5YzNiZDYxNmE0NDhmYjk1YjNiZWUwZWFlZWU2NiIsImlhdCI6MTcxODc1NTU0NywiZXhwIjoyMDM0MTE1NTQ3fQ.s2k4dEZAJryVZE-BhCWib0yuLR7b-QeyW2t2k5pJ8C8"))
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {showingConfiguration = true}) {
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
            if webSocketClient.isConnected {
                if (webSocketClient.alarmState == "disarmed") {
                    Text("DISARMED")
                        .padding(5)
                        .font(.callout)
                        .background(Color(red: 0.3, green: 0.3, blue: 0.3))
                        .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .bold()
                }
                if (webSocketClient.alarmState == "arming") {
                    Text("ARMING")
                        .padding(5)
                        .font(.callout)
                        .background(Color(red: 0.8, green: 0.8, blue: 0.2))
                        .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .bold()
                }
                if (webSocketClient.alarmState == "armed_away") {
                    Text("ARMED AWAY")
                        .padding(5)
                        .font(.callout)
                        .background(Color(red: 0.2, green: 0.8, blue: 0.2))
                        .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .bold()
                }
                if (webSocketClient.alarmState == "pending") {
                    Text("PENDING")
                        .padding(5)
                        .font(.callout)
                        .background(Color(red: 0.8, green: 0.4, blue: 0.2))
                        .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .bold()
                }
                if (webSocketClient.alarmState == "triggered") {
                    Text("TRIGGERED")
                        .padding(5)
                        .font(.callout)
                        .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .bold()
                }
                
            }
            Spacer()
            if webSocketClient.isConnected {
                ControlView(webSocketClient: webSocketClient)
            } else {
                VStack {
                    if showError {
                        Text("No Connection")
                            .padding(10)
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
        let IPAddress = UserDefaults.standard.string(forKey: "IPAddress") ?? ""
        let port = UserDefaults.standard.string(forKey: "port") ?? ""
        let accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        if let url = URL(string: "ws://\(IPAddress):\(port)/api/websocket") {
            webSocketClient.disconnect()
            webSocketClient.url = url
            webSocketClient.accessToken = accessToken
            webSocketClient.connect()
        }
    }
}



#Preview {
    ContentView()
}
