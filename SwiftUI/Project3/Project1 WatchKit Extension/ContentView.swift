//
//  ContentView.swift
//  Project1 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("lineCount") var lineCount = 1

    @State private var notes = [Note]()
    @State private var text = ""

    var body: some View {
        VStack {
            HStack {
                TextField("Add new note", text: $text)

                Button {
                    guard text.isEmpty == false else { return }

                    let note = Note(id: UUID(), text: text)
                    notes.append(note)

                    text = ""
                    save()

                    text = ""
                } label: {
                    Image(systemName: "plus")
                        .padding()
                }
                .fixedSize()
                .buttonStyle(BorderedButtonStyle(tint: .blue))
            }

            List {
                ForEach(0..<notes.count, id: \.self) { i in
                    NavigationLink(destination: DetailView(index: i, note: notes[i])) {
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
        }
        .navigationTitle("NoteDictate")
        .onAppear(perform: load)
    }

    func delete(offsets: IndexSet) {
        withAnimation {
            notes.remove(atOffsets: offsets)
            save()
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func load() {
        DispatchQueue.main.async {
            do {
                let url = getDocumentsDirectory().appendingPathComponent("notes")
                let data = try Data(contentsOf: url)
                notes = try JSONDecoder().decode([Note].self, from: data)
            } catch {
                // do nothing
            }
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(notes)
            let url = getDocumentsDirectory().appendingPathComponent("notes")
            try data.write(to: url)
        } catch {
            print("Save failed")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
