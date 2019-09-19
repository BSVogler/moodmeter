//
//  Model.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 30.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import Alamofire
import UIKit.UIColor

typealias Mood = Int

extension Mood {
	func getSmiley() -> String {
		return Face.moodToText[self]
	}
	
	func getColor() -> UIColor {
		return Face.moodToColor[self]
	}
}

class Model: Codable {
	// MARK: Constants
	//https://en.wikipedia.org/wiki/Birthday_attack
	//with alphabet of 34 there are ~3*10^20 possibilities. Birthday paradoxon colission probability is aprox 10^-8 after 2.4 Mio tries
	//for 5 107 billion tries are needed
	static let hashlength = 5;
	static let alphabet: [Character] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
	static let fileNameDB = "data.json"
	static var localDBStorageURL: URL {
		guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Can't access the document directory in the user's home directory.")
		}
		return documentsDirectory.appendingPathComponent(fileNameDB)
	}
	
	public static let shared : Model = {
		let model: Model? = loadFromFiles()
		guard let modelg = model else {
			return Model()
		}
		return modelg
	}()
	
	// MARK: stored properties
	public private(set) var userHash: String?
	var reminderEnabled: Bool = false
	var reminderHour = 22
	var reminderMinute = 00
	var password: String? = "todo"
	/// for getting the measurements as a read only array use `measurements`
	var dataset = [Date: Mood]()
	
	let baseURL = URL(string: "https://mood.benediktsvogler.com")!
	// MARK: Computed Properties
	var sharingURL: URL? {
		get{
			guard let deviceHash = self.userHash else {
				return nil
			}
			return baseURL.appendingPathComponent(deviceHash)
		}
	}
	
	var sharingURLShort: String? {
		get{
			guard let sharingURL = self.sharingURL else {
				return nil
			}
			return (sharingURL.host ?? "")+sharingURL.path
		}
	}
	
	var measurements: [Measurement] {
		get {
			return dataset.map{Measurement(day: $0.key, mood: $0.value)}
		}
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
	
	// MARK: Methods
	/// if there is already a hash, it moves them
	final func generateAndRegisterHash(done: @escaping () -> Void){
		generateHash()
		if let hash = userHash {
			moveHash(to: hash, done: done)
		} else {
			MoodAPIjsonHttpClient.shared.postMeasurement(measurements: measurements){ res in
				done()
			}
		}
	}
	
	final func generateHash() {
		//the hash does not have to be secure, just the seed, so use secure seed directly
		var bytes = [UInt8](repeating: 0, count: Model.hashlength)
		let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		
		if status == errSecSuccess { // Always test the status.
			let toURL: String = String(bytes.map{ byte in Model.alphabet[Int(byte % UInt8(Model.alphabet.count))] })
			userHash = toURL
			_ = saveToFiles()
		}
	}
	
	//I would like to return a more generic Result<>, but I was not able to do this
	func importHash(_ hash: String, done: @escaping () -> Void) {
		if (userHash == nil) {
			generateAndRegisterHash(done: done)
		} else {
			moveHash(to: hash, done: done)
		}
	}
	//I would like to return a more generic Result<>, but I was not able to do this
	func moveHash(to: String, done: @escaping () -> Void) {
		if let userHash = self.userHash {
			MoodAPIjsonHttpClient.shared.moveHash(old: userHash, new: to) { res in
				self.userHash = to //use new only after request completed
				done()
			}
		} else {
			generateAndRegisterHash(done: done)
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
	
	func disableSharing(){
		userHash = nil
		_ = saveToFiles()
	}
}

