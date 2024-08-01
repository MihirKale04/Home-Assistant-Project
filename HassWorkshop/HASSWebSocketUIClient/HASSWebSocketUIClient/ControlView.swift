//
//  ControlView.swift
//  HASSWebSocketUIClient
//
//  Created by Mihir Kale on 7/23/24.
//

import SwiftUI


struct ControlView: View {
    @ObservedObject var webSocketClient: WebSocketClient
    @State var code: String = ""
    
    var body: some View {
        VStack(spacing: 15) {
            if (webSocketClient.alarmState == "disarmed") {
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
            } else {

                KeypadView(enteredCode: $code)
                Button("Disarm Alarm") {
                    webSocketClient.disarmAlarm(code: code)
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
                .foregroundColor(.white)
                .background(Color(red: 0.1, green: 0.1,  blue: 0.2))
                .cornerRadius(30)
                .shadow(radius: 10)
                .font(.largeTitle)
                .bold()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct KeypadView: View {
    @Binding var enteredCode: String
    let maxCodeLength: Int = 4
    
    var body: some View {
        VStack(spacing: 10) {
            Text(enteredCode)
                .font(.largeTitle)
                .frame(width: 200, height: 50)
                .border(Color(red: 0.3, green: 0.3, blue: 0.3), width: 2)
                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
                .background(Color(red: 0.4, green: 0.4, blue: 0.4))
                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                
            
            ForEach(0..<3) { row in
                HStack(spacing: 10) {
                    ForEach(1..<4) { col in
                        Button(action: {
                            addDigit("\(row * 3 + col)")
                        }) {
                            Text("\(row * 3 + col)")
                                .font(.largeTitle)
                                .frame(width: 60, height: 60)
                                .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        }
                    }
                }
            }
            
            HStack(spacing: 10) {
                Button(action: {
                    addDigit("0")
                }) {
                    Text("0")
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(Color(red: 0.2, green: 0.2, blue: 0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }
                
                Button(action: {
                    deleteDigit()
                }) {
                    Text("⌫")
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(Color(red: 0.3, green: 0.1, blue: 0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                }
            }
        }
        .padding()
    }
    
    private func addDigit(_ digit: String) {
        if enteredCode.count < maxCodeLength {
            enteredCode.append(digit)
        }
    }
    
    private func deleteDigit() {
        if !enteredCode.isEmpty {
            enteredCode.removeLast()
        }
    }
//    
//    private func submitCode() {
//        // Handle the code submission logic here
//        print("Entered Code: \(enteredCode)")
//    }
}


#Preview {
    ControlView(webSocketClient: WebSocketClient(url: URL(string: "ws://192.168.68.79:8123/api/websocket")!, accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxNGI5YzNiZDYxNmE0NDhmYjk1YjNiZWUwZWFlZWU2NiIsImlhdCI6MTcxODc1NTU0NywiZXhwIjoyMDM0MTE1NTQ3fQ.s2k4dEZAJryVZE-BhCWib0yuLR7b-QeyW2t2k5pJ8C8"))
}

