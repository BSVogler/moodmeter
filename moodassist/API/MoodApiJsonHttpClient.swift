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
            let normalizedDate = date.normalized()
            if let mood = Int(item[1]) {
                // replace mood value if existing
                if let existingMsmtEntry = DataHandler.userProfile.dataset.first(where: {$0.day == normalizedDate}) {
                    existingMsmtEntry.mood = mood
                } else {
                    // append
                    DataHandler.userProfile.dataset.append(Measurement(day: date, mood: mood))
                }
            }
		}
	}
	
	public func register(measurements: [Measurement], done: @escaping (Result<RegisterResponse>) -> Void){
		let mrequest = MeasurementRequest(password: DataHandler.userProfile.sharingHash.password ?? "",
										  measurements: measurements)
		post(to: "/register/",
			 with: mrequest,
			 responseType: .json,
			 done: done
		)
	}
	
	public func moveHash(old: String, done: @escaping (Result<RegisterResponse>) -> Void){
		let moveRequest = MoveRequest(password: DataHandler.userProfile.sharingHash.password ?? "",
									  old_password: DataHandler.userProfile.sharingHash.password ?? "",
									  old_hash: old)
		post(to: "/register/",
			 with: moveRequest,
			 responseType: .json,
			 done: done
			)
	}
	
	public func importHash(old: String, new: String, done: @escaping (Result<[[String]]>) -> Void){
		let moveRequest = MoveRequest(password: DataHandler.userProfile.sharingHash.password ?? "",
									  old_password: DataHandler.userProfile.sharingHash.password ?? "",
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
	}
	
	public func postMeasurement(measurements: [Measurement], done: @escaping (Result<[[String]]>) -> Void){
        if let userHash = DataHandler.userProfile.sharingHash.userHash {
            let mrequest = MeasurementRequest(password: DataHandler.userProfile.sharingHash.password ?? "",
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
			logger.error("no device Hash")
		}
	}
	
	public func delete(done: @escaping (Result<DeleteRequest>) -> Void){
		if let userHash = DataHandler.userProfile.sharingHash.userHash {
            let del_request = DeleteRequest(password: DataHandler.userProfile.sharingHash.password ?? "")
			delete(to: userHash,
				   with: del_request,
				   done: done)
		} else {
			logger.error("no device Hash")
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
