//
//  Project4App.swift
//  Project4 Watch App
//
//  Created by Paul Hudson on 07/10/2022.
//

import SwiftUI

@main
struct Project4_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                 ContentView()
                 CurrenciesView()
             }
        }
    }
}
