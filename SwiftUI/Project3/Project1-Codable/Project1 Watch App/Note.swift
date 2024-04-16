//
//  Note.swift
//  Project1 Watch App
//
//  Created by Paul Hudson on 22/09/2022.
//

import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    let text: String
}
