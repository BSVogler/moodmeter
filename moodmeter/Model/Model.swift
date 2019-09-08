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
		static let fileName = "mooddb.json"
		static var localStorageURL: URL {
			guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
				fatalError("Can't access the document directory in the user's home directory.")
			}
			return documentsDirectory.appendingPathComponent(Constants.fileName)
		}
	}
	
	public static let shared = Model()
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
		//load from file
		loadFromJSON()
	}
	
	final func generateSharingURL(){
		//the hash does not have to be secure, just the seed, so use secure seed directly
		var bytes = [UInt8](repeating: 0, count: 40)
		let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		
		if status == errSecSuccess { // Always test the status.
			let letters: [Character] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]
			let toURL: String = String(bytes.map{ byte in letters[Int(byte % UInt8(letters.count))] })
			Model.shared.deviceHash = toURL
		}
	}
	
	// MARK: Type Methods
	func loadFromJSON() {
		do {
			let jsonData = try Data(contentsOf: Constants.localStorageURL)
			dataset = try JSONDecoder().decode([Date: Mood].self, from: jsonData)
			
			print("Decoded \(dataset.count) entries.")
		} catch _ {
			print("Could not load data")
		}
	}
	
	func saveToJSON() {
		do {
			let data = try JSONEncoder().encode(dataset)
			let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
			try jsonFileWrapper.write(to: Constants.localStorageURL, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
			print("Saved account.")
		} catch _ {
			print("Could not save Account")
		}
	}
	
	func eraseData() -> Bool {
		do {
			try FileManager().removeItem(at: Constants.localStorageURL)
		} catch _ {
			print("Could not delete data.")
			return false
		}
		return true
	}
	
}

