//
//  Constants.swift
//  Moodtracker
//
//  Created by Lukas Gerhardt on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - Hosts
enum Hosts {
    
    // MARK: Type Properties
    static let baseURL = NSURL(string: "https://mood.benediktsvogler.com")! as URL
}

// MARK: - LocalStorageConstants
enum LocalStorageConstants {
    
    static let databaseFileName = "data.json"
    static var documentDirectoryStorageURL: URL {
        guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Can't access the document directory in the user's home directory.")
        }
        return documentsDirectory.appendingPathComponent(databaseFileName)
    }
}
