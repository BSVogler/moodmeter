//
//  Model.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 30.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

class Model {
	// MARK: Constants
	private enum Constants {
		static let fileNameDB = "mooddb.json"
		static let fileNameHash = "hash.json"
		static var localDBStorageURL: URL {
			guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
				fatalError("Can't access the document directory in the user's home directory.")
			}
			return documentsDirectory.appendingPathComponent(Constants.fileNameDB)
		}
		static var localHashStorageURL: URL {
			guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
				fatalError("Can't access the document directory in the user's home directory.")
			}
			return documentsDirectory.appendingPathComponent(Constants.fileNameHash)
		}
	}
	
	public static let shared = Model()
	
	// MARK: stored properties
	public private(set) var deviceHash: String?
	var dataset = [Date: Mood]()

	// MARK: Computed Properties
	var sharingURL: String {
		get{ if self.deviceHash==nil {
				generateSharingURL()
			}
			guard let deviceHash = self.deviceHash else {
				return ""
			}
			return "https://mood.benediktsvogler.com/" + deviceHash
		}
	}
	
	init() {
		_ = loadFromJSON()
	}
	
	final func generateSharingURL(){
		//the hash does not have to be secure, just the seed, so use secure seed directly
		var bytes = [UInt8](repeating: 0, count: 10)
		let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		
		if status == errSecSuccess { // Always test the status.
			let letters: [Character] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
			let toURL: String = String(bytes.map{ byte in letters[Int(byte % UInt8(letters.count))] })
			Model.shared.deviceHash = toURL
		}
	}
	
	// MARK: Type Methods
	func loadFromJSON() -> Bool {
		do {
			let jsonData = try Data(contentsOf: Constants.localDBStorageURL)
			dataset = try JSONDecoder().decode([Date: Mood].self, from: jsonData)
			print("Decoded \(dataset.count) entries.")
			
			if FileManager().fileExists(atPath: Constants.localHashStorageURL.absoluteString){
				deviceHash = try String(contentsOf: Constants.localHashStorageURL, encoding: .utf8)
			}
			return true
		} catch _ {
			print("Could not load all data")
			return false
		}
	}
	
	func saveToJSON() -> Bool {
		do {
			let data = try JSONEncoder().encode(dataset)
			let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
			try jsonFileWrapper.write(to: Constants.localDBStorageURL, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
			print("Saved database.")
			
			if let deviceHash = deviceHash {
				try deviceHash.write(to: Constants.localHashStorageURL, atomically: true, encoding: .utf8)
				print("Saved hash")
			}
			return true
		} catch _ {
			print("Could not save all data.")
			return false
		}
	}
	
	func eraseData() -> Bool {
		do {
			let fm = FileManager()
			try fm.removeItem(at: Constants.localDBStorageURL)
			if fm.fileExists(atPath: Constants.localHashStorageURL.absoluteString){
				try fm.removeItem(at: Constants.localHashStorageURL)
			}
		} catch _ {
			print("Could not delete all data.")
			return false
		}
		return true
	}
	
}

