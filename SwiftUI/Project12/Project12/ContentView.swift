//
//  ContentView.swift
//  Project12
//
//  Created by Paul Hudson on 07/10/2020.
//

import SwiftUI

struct ContentView: View {
    @StateObject var connectivity = Connectivity()

    var body: some View {
        VStack(spacing: 30) {
            Button("Message", action: sendMessage)
            Button("Context", action: sendContext)
            Button("File", action: sendFile)
            Button("Complication", action: sendComplication)
        }
    }

    func sendMessage() {
//        let data = ["text": "User info from the phone"]
//        connectivity.transferUserInfo(data)

        let data = ["text": "A message from the phone"]
        connectivity.sendMessage(data)
    }

    func sendContext() {
        let data = ["text": "Hello from the phone"]
        connectivity.setContext(to: data)
    }

    func sendFile() {
        let fm = FileManager.default
        let sourceURL = getDocumentsDirectory().appendingPathComponent("saved_file")

        if fm.fileExists(atPath: sourceURL.path) == false {
            try? "Hello, from a phone file".write(to: sourceURL, atomically: true, encoding: .utf8)
        }

        connectivity.sendFile(sourceURL)
    }

    func sendComplication() {
        let randomNumber = String(Int.random(in: 0...9))
        let message = ["number": randomNumber]
        connectivity.updateComplication(with: message)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
