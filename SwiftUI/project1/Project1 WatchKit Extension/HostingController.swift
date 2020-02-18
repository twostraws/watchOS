//
//  HostingController.swift
//  Project1 WatchKit Extension
//
//  Created by Paul Hudson on 18/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
        return ContentView()
    }
}

class CurrenciesHostingController: WKHostingController<CurrenciesView> {
    override var body: CurrenciesView {
        return CurrenciesView()
    }
}
