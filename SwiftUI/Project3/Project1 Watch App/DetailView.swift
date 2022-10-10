//
//  DetailView.swift
//  Project1 Watch App
//
//  Created by Paul Hudson on 22/09/2022.
//

import SwiftUI

struct DetailView: View {
    let index: Int
    let note: Note
    
    var body: some View {
        Text(note.text)
            .navigationTitle("Note \(index + 1)")
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DetailView(index: 1, note: Note(id: UUID(), text: "Example Note"))
        }
    }
}
