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
	//MARK: Stored Instance Properties
	let apiURL = Foundation.URL(string: "https://api.moodassist.cloud")
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
			return Foundation.URL(string: "https://moodassist.cloud")!.appendingPathComponent("c/").appendingPathComponent(deviceHash)
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
	final func registerHash(done: @escaping (Bool, Error?) -> Void){
		if let old = self.userHash {
			MoodApiJsonHttpClient.shared.moveHash(old: old) { res in
				self.resultRegister(done: done, res: res)
			}
		} else {
			MoodApiJsonHttpClient.shared.register(measurements: Model.shared.measurements) { res in
				self.resultRegister(done: done, res: res)
			}
		}
	}
	
	//I would like to return a more generic Result<>, but I was not able to do this
	func importHash(_ hash: String, done: @escaping (Bool, Error?) -> Void) {
		guard userHash != nil else {
			//this should not happen
			return
		}
		if hash.count > 1 {
			if let old = self.userHash {
				MoodApiJsonHttpClient.shared.importHash(old: old, new: hash) { res in
					if res.isSuccess {
						self.userHash = hash //use new only after request completed
						_ = Model.shared.saveToFiles()
					}
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
	
	func refresh(done: @escaping ()-> Void ){
		if let userHash = userHash {
			MoodApiJsonHttpClient.shared.getData(hash: userHash){ res in
				done()
			}
		}
	}
}
