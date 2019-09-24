//
//  Sharing.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 23.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

class Sharing: Codable {
	
	//https://en.wikipedia.org/wiki/Birthday_attack
	//with alphabet of 34 there are ~3*10^20 possibilities. Birthday paradoxon colission probability is aprox 10^-8 after 2.4 Mio tries
	//for 5 107 billion tries are needed
	static let hashlength = 10;
	static let alphabet: [Character] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
	
	//MARK: Stored Properties
	public private(set) var userHash: String?
	var password: String? = "todo"
	let baseURL = NSURL(string: "https://mood.benediktsvogler.com")! as URL
	
	// MARK: Computed Properties
	var URL: URL? {
		get{
			guard let deviceHash = self.userHash else {
				return nil
			}
			return baseURL.appendingPathComponent(deviceHash)
		}
	}
	
	//url without protocoll
	var URLwithoutProtocol: String? {
		get{
			guard let sharingURL = self.URL else {
				return nil
			}
			return (sharingURL.host ?? "")+sharingURL.path
		}
	}
	
	// MARK: Methods
	/// if there is already a hash, it moves them
	final func generateAndRegisterHash(done: @escaping () -> Void){
		let oldHash = userHash
		//the hash does not have to be secure, just the seed, so use secure seed directly
		var bytes = [UInt8](repeating: 0, count: Sharing.self.hashlength)
		let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
		
		if status == errSecSuccess { // Always test the status.
			let toURL = String(bytes.map{ byte in Sharing.alphabet[Int(byte % UInt8(Sharing.alphabet.count))] })
			if oldHash != nil {
				moveHash(to: toURL){
					_ = Model.shared.saveToFiles()
					done()
				}
			} else {
				//create by just posting
				userHash = toURL
				let apimeasures = Model.shared.measurements.map{ $0.apiMeasurement }
				MoodAPIjsonHttpClient.shared.postMeasurement(measurements: apimeasures){ res in
					_ = Model.shared.saveToFiles()
					done()
				}
			}
		}
	}
	
	//I would like to return a more generic Result<>, but I was not able to do this
	func importHash(_ hash: String, done: @escaping () -> Void) {
		guard userHash != nil else {
			//this should not happen
			generateAndRegisterHash(done: done)
			return
		}
		moveHash(to: hash, done: done)
	}
	//I would like to return a more generic Result<>, but I was not able to do this
	func moveHash(to: String, done: @escaping () -> Void) {
		if let old = self.userHash {
			MoodAPIjsonHttpClient.shared.moveHash(old: old, new: to) { res in
				self.userHash = to //use new only after request completed
				done()
			}
		} else {
			generateAndRegisterHash(done: done)
		}
	}
	
	func disableSharing(){
		userHash = nil
		_ = Model.shared.saveToFiles()
	}
	
	func refresh(){
		if let userHash = userHash {
			MoodAPIjsonHttpClient.shared.getData(hash: userHash){ res in
			}
		}
	}
}
