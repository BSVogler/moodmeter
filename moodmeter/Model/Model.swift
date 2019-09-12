//
//  Model.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 30.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

class Model: Decodable {
	// MARK: Constants
	private enum Constants {
		static let fileNameDB = "mooddb.json"
		static let fileNameApplicationData = "applicationdata.plist"
		static var localDBStorageURL: URL {
			guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
				fatalError("Can't access the document directory in the user's home directory.")
			}
			return documentsDirectory.appendingPathComponent(Constants.fileNameDB)
		}
		static var localApplicationDataURL: URL {
			guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
				fatalError("Can't access the document directory in the user's home directory.")
			}
			return documentsDirectory.appendingPathComponent(Constants.fileNameApplicationData)
		}
	}
	
	public static let shared : Model = {
		let model: Model? = loadFromFiles()
		guard let modelg = model else {
			return Model()
		}
		return modelg
	}()
	
	// MARK: stored properties
	public private(set) var deviceHash: String?
	var reminderEnabled: Bool = false
	var reminderHour = 22
	var reminderMinute = 00
	var password = "todo"
	
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
	
	// MARK: Type Methods
	static func loadFromFiles() -> Model? {
		do {
			var loaded_model: Model? = nil
			if FileManager().fileExists(atPath: Constants.localApplicationDataURL.relativePath){
				let data = try! Data(contentsOf: Constants.localApplicationDataURL)
				let decoder = PropertyListDecoder()
				loaded_model = try! decoder.decode(Model.self, from: data)
				print("Loaded application data from \(Constants.localApplicationDataURL.relativePath)")
			} else {
				print("No file at \(Constants.localApplicationDataURL.relativePath)")
			}
			
			if loaded_model == nil {
				loaded_model = Model()
			}
			let jsonData = try Data(contentsOf: Constants.localDBStorageURL)
			let dataset = try JSONDecoder().decode([Date: Mood].self, from: jsonData)
			print("Decoded \(dataset.count) entries.")
			loaded_model?.dataset = dataset
			return loaded_model
		} catch _ {
			print("Could not load all data")
			return nil
		}
	}
	
	// MARK: Methods
	func saveApplicationData(){
		var dic:[String:Any] = Dictionary()
		if deviceHash != nil{
			dic["deviceHash"] = deviceHash
		}
		dic["reminderEnabled"] = reminderEnabled
		dic["reminderHour"] = reminderHour
		dic["reminderMinute"] = reminderMinute
		// Swift Dictionary To Data.
		do  {
			let data = try PropertyListSerialization.data(fromPropertyList: dic, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
			do {
				try data.write(to: Constants.localApplicationDataURL, options: .atomic)
				print("Successfully write to \(Constants.localApplicationDataURL.relativePath)")
			}catch (let err){
				print(err.localizedDescription)
			}
		}catch (let err){
			print(err.localizedDescription)
		}
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
	
	func saveToFiles() -> Bool {
		do {
			let data = try JSONEncoder().encode(dataset)
			let jsonFileWrapper = FileWrapper(regularFileWithContents: data)
			try jsonFileWrapper.write(to: Constants.localDBStorageURL, options: FileWrapper.WritingOptions.atomic, originalContentsURL: nil)
			print("Saved database.")
			
			saveApplicationData()
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
			if fm.fileExists(atPath: Constants.localApplicationDataURL.relativePath){
				try fm.removeItem(at: Constants.localApplicationDataURL)
			}
		} catch _ {
			print("Could not delete all data.")
			return false
		}
		return true
	}
	
	func disableSharing(){
		deviceHash = nil
	}
	
}

