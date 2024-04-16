//
//  ContentView.swift
//  Project12 Watch App
//
//  Created by Paul Hudson on 10/10/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var connectivity = Connectivity()
    
    var body: some View {
        VStack {
            Text(connectivity.receivedText)
            Button("Message", action: sendMessage)
        }
    }

    func sendMessage() {
        let data = ["text": "Hello from the watch"]
        connectivity.transferUserInfo(data)
    }
}

#Preview {
    ContentView()
}
