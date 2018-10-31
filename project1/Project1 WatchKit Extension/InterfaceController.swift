//
//  InterfaceController.swift
//  Project1 WatchKit Extension
//
//  Created by Paul Hudson on 16/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable!
    var notes = [String]()

    var savePath = InterfaceController.getDocumentsDirectory().appendingPathComponent("notes")

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        do {
            let data = try Data(contentsOf: savePath)
            notes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] ?? [String]()
        } catch {
            // do nothing; notes is already an empty array
        }
        
        table.setNumberOfRows(notes.count, withRowType: "Row")

        for rowIndex in 0 ..< notes.count {
            set(row: rowIndex, to: notes[rowIndex])
        }
    }

    func set(row rowIndex: Int, to text: String) {
        guard let row = table.rowController(at: rowIndex) as? NoteSelectRow else { return }
        row.textLabel.setText(text)
    }

    @IBAction func addNewNote() {
        presentTextInputController(withSuggestions: nil, allowedInputMode: .plain) { [unowned self] result in
            guard let result = result?.first as? String else { return }

            self.table.insertRows(at: IndexSet(integer: self.notes.count), withRowType: "Row")
            self.set(row: self.notes.count, to: result)
            self.notes.append(result)

            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: self.notes, requiringSecureCoding: false)
                try data.write(to: self.savePath)
            } catch {
                print("Failed to save data: \(error.localizedDescription).")
            }
        }
    }

    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return ["index": String(rowIndex + 1), "note": notes[rowIndex]]
    }

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
