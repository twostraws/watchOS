//
//  Note.swift
//  Project1 Watch App
//
//  Created by Paul Hudson on 22/09/2022.
//

import Foundation
import SwiftData

@Model
class Note {
    let text: String
    let dateAdded: Date

    init(text: String) {
        self.text = text
        self.dateAdded = .now
    }
}
