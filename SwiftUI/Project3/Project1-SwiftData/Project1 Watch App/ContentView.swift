//
//  ContentView.swift
//  Project1 Watch App
//
//  Created by Paul Hudson on 22/09/2022.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \Note.dateAdded, order: .reverse) private var notes: [Note]
    @Environment(\.modelContext) var modelContext
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            HStack {
                TextField("Add new note", text: $text)
                
                Button {
                    guard text.isEmpty == false else { return }
                    
                    let note = Note(text: text)
                    modelContext.insert(note)
                    text = ""
                } label: {
                    Image(systemName: "plus")
                        .padding()
                }
                .fixedSize()
                .tint(.blue)
            }
            
            List {
                ForEach(0..<notes.count, id: \.self) { i in
                    if i < notes.count {
                        NavigationLink {
                            DetailView(index: i, note: notes[i])
                        } label: {
                            Text(notes[i].text)
                                .lineLimit(1)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("NoteDictate")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func delete(offsets: IndexSet) {
        for offset in offsets {
            let note = notes[offset]
            modelContext.delete(note)
        }
    }
}

#Preview {
    ContentView()
}
