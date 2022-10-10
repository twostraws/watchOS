//
//  Connectivity.swift
//  Project12
//
//  Created by Paul Hudson on 10/10/2022.
//

import Foundation
import WatchConnectivity

class Connectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedText = ""
    
    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    #if os(iOS)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if activationState == .activated {
                if session.isWatchAppInstalled {
                    self.receivedText = "Watch app is installed!"
                }
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #else
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    #endif
    
    func transferUserInfo(_ userInfo: [String: Any]) {
        let session = WCSession.default

        if session.activationState == .activated {
            session.transferUserInfo(userInfo)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        Task { @MainActor in
            if let text = userInfo["text"] as? String {
                self.receivedText = text
            }
        }
    }

    func sendMessage(_ data: [String: Any]) {
        let session = WCSession.default

        if session.isReachable {
            session.sendMessage(data) { response in
                Task { @MainActor in
                    self.receivedText = "Received response: \(response)"
                }
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            if let text = message["text"] as? String {
                self.receivedText = text
                replyHandler(["response": "Be excellent to each other"])
            }
        }
    }
    
    func setContext(to data: [String: Any]) {
        let session = WCSession.default

        if session.activationState == .activated {
            do {
                try session.updateApplicationContext(data)
            } catch {
                receivedText = "Alert! Updating app context failed"
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.receivedText = "Application context received: \(applicationContext)"
        }
    }
    
    func sendFile(_ url: URL) {
        let session = WCSession.default

        if session.activationState == .activated {
            session.transferFile(url, metadata: nil)
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let fm = FileManager.default
        let destURL = URL.documentsDirectory.appending(path: "saved_file")

        do {
            if fm.fileExists(atPath: destURL.path) {
                try fm.removeItem(at: destURL)
            }

            try fm.copyItem(at: file.fileURL, to: destURL)
            let contents = try String(contentsOf: destURL)
            receivedText = "Received file: \(contents)"
        } catch {
            receivedText = "File copy failed."
        }
    }
}
