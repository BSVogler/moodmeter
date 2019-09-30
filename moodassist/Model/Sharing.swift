//
//  Sharing.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 23.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import Alamofire

// MARK: Sharing
class Sharing: Codable {
	
	//https://en.wikipedia.org/wiki/Birthday_attack
	//with alphabet of 34 there are ~3*10^20 possibilities. Birthday paradoxon colission probability is aprox 10^-8 after 2.4 Mio tries
	//for 5 107 billion tries are needed
	static let hashlength = 10;
	static let alphabet: [Character] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
	
	//MARK: Stored Instance Properties
    let baseURL = NSURL(string: "https://moodassist.cloud")! as URL
	private(set) var userHash: String? {
		get {
			return self._userHash
		}
		set {
			self._userHash = newValue?.uppercased()
		}
	}
	var _userHash: String?
	var password: String? = "todo"

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
	
	
	private func resultRegister(done: @escaping (Bool, Error?) -> Void, res: Result<RegisterResponse>) -> Void {
		if res.isSuccess {
			if let userHash =  res.value?.hash {
				self.userHash = userHash
				_ = Model.shared.saveToFiles()
			} else {
				done(false, NSError(domain: "got no hash", code: 1, userInfo: nil))
			}
		}
		done(res.isSuccess, res.error)
	}
	
	// MARK: Instance Methods
	/// if there is already a hash, it moves them
	final func generateAndRegisterHash(done: @escaping (Bool, Error?) -> Void){
		if let old = self.userHash {
			MoodApiJsonHttpClient.shared.moveHash(old: old) { res in
				self.resultRegister(done: done, res: res)
			}
		} else {
			//create by just posting
			MoodApiJsonHttpClient.shared.register(measurements: Model.shared.measurements) { res in
				self.resultRegister(done: done, res: res)
			}
		}
	}
	
	//I would like to return a more generic Result<>, but I was not able to do this
	func importHash(_ hash: String, done: @escaping (Bool, Error?) -> Void) {
		guard userHash != nil else {
			//this should not happen
			generateAndRegisterHash(done: done)
			return
		}
		if Sharing.hashlength == hash.count {
			if let old = self.userHash {
				MoodApiJsonHttpClient.shared.importHash(old: old, new: hash) { res in
					self.userHash = hash //use new only after request completed
					_ = Model.shared.saveToFiles()
					done(res.isSuccess, res.error)
				}
			}
		} else {
			done(false, NSError(domain: "Invalid import call. no hash found", code: 13, userInfo: nil))
		}
	}
    
	func disableSharing(){
		userHash = nil
		_ = Model.shared.saveToFiles()
	}
	
	func refresh(){
		if let userHash = userHash {
			MoodApiJsonHttpClient.shared.getData(hash: userHash){ res in
			}
		}
	}
}
