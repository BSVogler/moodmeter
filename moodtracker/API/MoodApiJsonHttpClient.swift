//
//  MoodApiJsonHttpClient.swift
//  Moodmeter
//
//  Created by Benedikt Stefan Vogler on 10.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import Alamofire

// MARK: - MoodApiJsonHttpClient
class MoodApiJsonHttpClient: JsonHttpClient {
    
    // MARK: Stored Type Properties
    public static let shared = MoodApiJsonHttpClient()
	
    // MARK: Stored Instance Properties
    var userProfile = DataHandler.userProfile
    
    // MARK: Initializers
	init() {
		super.init(Hosts.baseURL)
		super.jsonDecoder.dateDecodingStrategy = .formatted(Date.dateFormatter)
		super.jsonEncoder.dateEncodingStrategy = .formatted(Date.dateFormatter)
	}
	
    // MARK: Instance Methods
	public func parseToDataset(_ input: [[String]]){
		for item in input {
            // TODO: What is at 0, 1? Use descriptive values or add documentation
			guard let date = Date.fromJS(item[0]) else {
				print("Could not parse String (\(item[0])) to Date")
				continue
			}
            
            if let mood = Int(item[1]) {
                // replace mood value if existing
                if let existingMsmtEntry = userProfile.dataset.first(where: {$0.day == date}) {
                    existingMsmtEntry.mood = mood
                } else {
                    // append
                    userProfile.dataset.append(Measurement(day: date, mood: mood))
                }
            }
		}
	}
	
    // Can this take single measurements or only the whole dataset? Update documentation, please.
	public func postMeasurement(measurements: [Measurement], done: @escaping (Result<[[String]]>) -> Void){
		if let sharingHash = userProfile.sharingHash,
            let userHash = sharingHash.userHash {
            
            let mrequest = MeasurementRequest(password: sharingHash.password ?? "",
                                              measurements: measurements)
            post(to: userHash,
				 with: mrequest,
				 responseType: .csv,
				 done: {(res: Result<[[String]]>) in
					if res.isSuccess, let value = res.value {
						self.parseToDataset(value)
					}
					done(res)
			})
		} else {
			logger.error("No user hash")
		}
	}
	
	public func delete(done: @escaping (Result<DeleteRequest>) -> Void){
        
		if let sharingHash = userProfile.sharingHash,
        let userHash = sharingHash.userHash {
			let delRequest = DeleteRequest(password: sharingHash.password ?? "")
			delete(to: userHash,
				   with: delRequest,
				   done: done)
		} else {
			logger.error("No user hash")
		}
	}
	
	public func moveHash(old: String, new: String, done: @escaping (Result<[[String]]>) -> Void) {
        
        if let sharingHash = userProfile.sharingHash {
            let moveRequest = MoveRequest(password: sharingHash.password ?? "",
                                          old_password: sharingHash.password ?? "",
                                          old_hash: old)
            post(to: new,
                 with: moveRequest,
                 responseType: .csv,
                 done: {(res: Result<[[String]]>) in
                    if res.isSuccess, let value = res.value {
                        self.parseToDataset(value)
                    }
                    done(res)
            })
        } else {
            
            logger.error("No user hash")
        }
	}
	
	public func getData(hash: String, done: @escaping (Result<[[String]]>) -> Void){
		get(to: hash, done: {(res: Result<[[String]]>) in
				if res.isSuccess, let value = res.value {
					self.parseToDataset(value)
				}
				done(res)
		})
	}
}
