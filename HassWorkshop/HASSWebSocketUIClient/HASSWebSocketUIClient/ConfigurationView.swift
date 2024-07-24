//
//  ConfigurationView.swift
//  HASSWebSocketUIClient
//
//  Created by Mihir Kale on 7/15/24.
//

import SwiftUI

struct ConfigurationView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("accessToken") private var accessToken: String = ""
    @AppStorage("webSocketURL") private var webSocketURL: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    var onSave: (() -> Void)? // Add this callback


    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Access Token", text: $accessToken)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("WebSocket URL", text: $webSocketURL)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Save") {
                onSave?() // Call the callback when Save is tapped
                // Save is handled automatically by @AppStorage
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0, green: 0.2, blue: 0.2))
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}

