//
//  Note.swift
//  Project1 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    let text: String
}
