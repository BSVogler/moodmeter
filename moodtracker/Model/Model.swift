//
//  Model.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 30.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import Alamofire
import UIKit.UIColor

// MARK: Model
class Model: Codable {
    
	// MARK: Stored Type Properties
    // this code is only run when intializing, this is not a computed property
    public static let shared : Model = {
        let model = loadFromFiles() ?? Model()
        return model
    }()
    
	static let fileNameDB = "data.json"
	static var localDBStorageURL: URL {
		guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Can't access the document directory in the user's home directory.")
		}
		return documentsDirectory.appendingPathComponent(fileNameDB)
	}
	
	// MARK: Stored Instance Properties
	var reminderEnabled: Bool = false
	var reminderHour = 22
	var reminderMinute = 00
	/// for getting the measurements as a read only array use `measurements`
	var dataset = [Date: Mood]()
	let sharing: Sharing
	
	// MARK: Computed Properties
	var measurements: [Measurement] {
		get {
			return dataset.map{Measurement(day: $0.key, mood: $0.value)}
		}
	}
	
    // MARK: Initializers
	init(){
		//init sharing shere and not in constructor list, so it is loaded by hidden generated constructor
		sharing = Sharing()
	}
    
    // MARK: Type Methods
    static func loadFromFiles() -> Model? {
        do {
            let jsonData = try Data(contentsOf: localDBStorageURL)
            let model = try JSONDecoder().decode(Model.self, from: jsonData)
            print("Decoded \(model.dataset.count) entries.")
            return model
        } catch {
            print("Could not load all data: \(error)")
            return nil
        }
    }
	
	// MARK: Instance Methods
	func saveToFiles() -> Bool {
		do {
			let data = try JSONEncoder().encode(self)
			let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
			try jsonFileWrapper.write(to: Model.localDBStorageURL, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
			print("Saved database.")
			
			return true
		} catch _ {
			print("Could not save all data.")
			return false
		}
	}
	
	func exportCSV() -> String {
		return "Date; Mood\n"+dataset.map {return "\($0.key.toJS());\($0.value)"}.joined(separator: "\n")
	}
	
	func eraseData() -> Bool {
		do {
			let fm = FileManager()
			try fm.removeItem(at: Model.localDBStorageURL)
		} catch _ {
			print("Could not delete all data.")
			return false
		}
		dataset.removeAll()
		_ = saveToFiles()
		return true
	}
}
