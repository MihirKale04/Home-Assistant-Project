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
    @AppStorage("IPAddress") private var IPAddress: String = ""
    @AppStorage("port") private var port: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    var onSave: (() -> Void)? // Add this callback


    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            VStack(){
                TextField("Username", text: $username)
                    .frame(width: 300)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Username").foregroundColor(.white)
            }
            VStack{
                TextField("Access Token", text: $accessToken)
                    .frame(width: 300)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Access Token").foregroundColor(.white)
            }
            VStack{
                TextField("IP Address", text: $IPAddress)
                    .frame(width: 300)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("IP Address").foregroundColor(.white)
            }
            VStack {
                TextField("Port", text: $port)
                    .frame(width: 300)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Port").foregroundColor(.white)
            }
            Spacer()
            
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

