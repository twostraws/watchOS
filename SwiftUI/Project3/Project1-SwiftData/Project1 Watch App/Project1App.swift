//
//  Project1App.swift
//  Project1 Watch App
//
//  Created by Paul Hudson on 22/09/2022.
//

import SwiftData
import SwiftUI

@main
struct Project1_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Note.self)
    }
}
