//
//  Model.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 30.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

class Model {
	public static let shared = Model()
	public private(set) var deviceHash: String?
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
	var dataset = [Date: Mood]()
	
	init() {
		//load from file
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
}

