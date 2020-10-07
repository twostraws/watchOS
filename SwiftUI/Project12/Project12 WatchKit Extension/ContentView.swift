//
//  ContentView.swift
//  Project12 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import SwiftUI

struct ContentView: View {
    @StateObject var connectivity = Connectivity()

    var body: some View {
        VStack {
            Text("Response Text")
            Button("Message", action: sendMessage)
        }
    }

    func sendMessage() {
        let data = ["text": "Hello from the watch"]
        connectivity.transferUserInfo(data)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
