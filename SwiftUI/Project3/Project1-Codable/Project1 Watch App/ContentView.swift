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
    
    @AppStorage("lineCount") var lineCount = 1
    
    var body: some View {
        NavigationStack {
            HStack {
                TextField("Add new note", text: $text)
                
                Button {
                    guard text.isEmpty == false else { return }
                    
                    let note = Note(id: UUID(), text: text)
                    notes.append(note)
                    text = ""
                    save()
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
                            .lineLimit(lineCount)
                    }
                }
                .onDelete(perform: delete)
                
                Button("Lines: \(lineCount)") {
                    lineCount += 1

                    if lineCount == 4 {
                        lineCount = 1
                    }
                }
            }
            .navigationTitle("NoteDictate")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: load)
        }
    }
    
    func delete(offsets: IndexSet) {
        withAnimation {
            notes.remove(atOffsets: offsets)
            save()
        }
    }
    
    func load() {
        do {
            let url = URL.documentsDirectory.appending(path: "notes")
            let data = try Data(contentsOf: url)
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            // do nothing
        }
    }
    
    func save() {
        do {
            let data = try JSONEncoder().encode(notes)
            let url = URL.documentsDirectory.appending(path: "notes")
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("Save failed")
        }
    }
}

#Preview {
    ContentView()
}
