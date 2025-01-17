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
	var measurements: [Measurement] = []
	let sharing: Sharing
	
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
            print("Decoded \(model.measurements.count) entries.")
            return model
        } catch {
            print("Could not load all data: \(error)")
            return nil
        }
    }
	
	// MARK: Instance Methods
	///sorted insert
	func addMeasurment(_ new: Measurement) {
		if measurements.isEmpty {
			measurements.append(new)
		} else {
			for measure in measurements.enumerated() {
				if measure.element.day == new.day {
					measure.element.mood = new.mood
					return;
				} else if new.day < measure.element.day {
					//add before
					measurements.insert(new, at: measure.offset)
					return;
				}
			}
			measurements.append(new)
		}
		NotificationCenter.default.post(name: Measurement.changedNotification, object: nil)
	}
	
	///sorted insert of an array
	func addMeasurment(_ new: [Measurement]) {
		if measurements.isEmpty {
			measurements.append(contentsOf: new)
		} else {
			var newI = 0
			var i = 0
			while newI < new.count {
				let newMeasure = new[newI]
				let currentMeasure = measurements[i]
				if currentMeasure.day == newMeasure.day {
					currentMeasure.mood = newMeasure.mood
					newI += 1
				} else if newMeasure.day < currentMeasure.day {
					measurements.insert(newMeasure, at: i)
					newI += 1
				}
				if i+1 < measurements.count{
					i += 1
				} else {
					measurements.append(newMeasure)
					newI += 1
				}
			}
		}
		NotificationCenter.default.post(name: Measurement.changedNotification, object: nil)
	}
	
	
	///get the optional measurements from the dataset
	func getMeasurement(at day: Date) -> Measurement? {
		let normalizedDay = day.normalized()
		return measurements.first { $0.day==normalizedDay}
	}
	
	/// mood setter subscript for any entry (date)
    subscript(_ date: Date) -> Mood? {
        get {
			return getMeasurement(at: date)?.mood
        }
        set {
			guard let newMood = newValue else {
				assert(false, "Mood on \(date) cannot be nil.")
				return
            }
			//check if already existing
			if let existingMsmt = getMeasurement(at: date) {
				existingMsmt.mood = newMood
            } else {
				addMeasurment(Measurement(day: date, mood: newMood))
            }
        }
    }
	
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
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-DD"
		formatter.locale = Calendar.current.locale
		return "Date (YYYY-MM-DD); Mood\n"+measurements.map {return formatter.string(from: $0.day)+";\($0.mood)"}.joined(separator: "\n")
	}
	
	func eraseData() -> Bool {
		//remove file
		let fm = FileManager()
		if fm.fileExists(atPath: Model.localDBStorageURL.absoluteString) {
			do {
				try fm.removeItem(at: Model.localDBStorageURL)
			} catch _ {
				print("Could not delete all stored data.")
				return false
			}
		}
		measurements.removeAll()
		_ = saveToFiles()
		NotificationCenter.default.post(name: Measurement.erasedNotification, object: nil)
		return true
	}
}
