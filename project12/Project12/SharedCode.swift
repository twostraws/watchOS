//
//  SharedCode.swift
//  Project12
//
//  Created by Paul Hudson on 04/04/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import Foundation

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
