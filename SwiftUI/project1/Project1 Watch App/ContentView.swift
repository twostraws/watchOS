//
//  ContentView.swift
//  Project1 Watch App
//
//  Created by Paul Hudson on 22/09/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var notes = [Note]()
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            HStack {
                TextField("Add new note", text: $text)
                
                Button {
                    guard text.isEmpty == false else { return }
                    
                    let note = Note(id: UUID(), text: text)
                    notes.append(note)
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
                    NavigationLink {
                        DetailView(index: i, note: notes[i])
                    } label: {
                        Text(notes[i].text)
                            .lineLimit(1)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("NoteDictate")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func delete(offsets: IndexSet) {
        withAnimation {
            notes.remove(atOffsets: offsets)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
