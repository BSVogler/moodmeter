//
//  DataHandler.swift
//  Moodtracker
//
//  Created by Lukas Gerhardt on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: Datahandler
enum DataHandler {
    
    // MARK: Type Properties
    static var userProfile = Profile()
    
    // MARK: Type Methods
    static func loadFromFiles() -> Profile? {
        do {
            let jsonData = try Data(contentsOf: LocalStorageConstants.documentDirectoryStorageURL)
            let profile = try JSONDecoder().decode(Profile.self, from: jsonData)
            print("Decoded \(profile.dataset.count) entries.")
            return profile
        } catch {
            print("Could not load all data: \(error)")
            return nil
        }
    }
    
    static func saveToFiles() -> Bool {
        do {
            let data = try JSONEncoder().encode(userProfile)
            let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
            try jsonFileWrapper.write(to: LocalStorageConstants.documentDirectoryStorageURL, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
            print("Saved database.")
            
            return true
        } catch _ {
            print("Could not save all data.")
            return false
        }
    }
    
    static func exportCSV() -> String {
        return "Date; Mood\n" + userProfile.dataset
            .map{ "\($0.day.toJS());\($0.mood)" }
            .joined(separator: "\n")
    }
    
    /// erases the user's whole `dataset` and returns whether the empty dataset was successfully saved locally
    static func eraseData() -> Bool {
        do {
            let fm = FileManager()
            try fm.removeItem(at: LocalStorageConstants.documentDirectoryStorageURL)
        } catch _ {
            print("Could not delete all data.")
            return false
        }
        userProfile.dataset.removeAll()
        return saveToFiles()
    }
}
