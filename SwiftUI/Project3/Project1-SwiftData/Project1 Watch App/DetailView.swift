//
//  DetailView.swift
//  Project1 Watch App
//
//  Created by Paul Hudson on 22/09/2022.
//

import SwiftData
import SwiftUI

struct DetailView: View {
    let index: Int
    let note: Note
    
    var body: some View {
        Text(note.text)
            .navigationTitle("Note \(index + 1)")
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Note.self, configurations: config)
        
        return NavigationStack {
            DetailView(index: 1, note: Note(text: "Example Note"))
        }
        .modelContainer(container)
    } catch {
        return Text("Failed to create model container: \(error.localizedDescription)")
    }
}
