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
    public static let shared = MoodApiJsonHttpClient(model: Model.shared)

    // MARK: Stored Instance Properties
	let model: Model
	
    // MARK: Initializers
	init(model: Model) {
		self.model = model
		super.init(model.sharing.baseURL)
		super.decoder.dateDecodingStrategy = .formatted(Measurement.dateFormatter)
		super.encoder.dateEncodingStrategy = .formatted(Measurement.dateFormatter)
	}
	
    // MARK: Instance Methods
	public func parseToDataset(_ input: [[String]]){
		for item in input {
			guard let date = Date.fromJS(item[0]) else {
				print("could not parse string (\(item[0])) to Date")
				continue
			}
			
			model.dataset[date] = Int(item[1])
		}
	}
	
	public func postMeasurement(measurements: [Measurement], done: @escaping (Result<[[String]]>) -> Void){
		if let deviceHash = model.sharing.userHash {
			let mrequest = MeasurementRequest(password: Model.shared.sharing.password ?? "",
											  measurements: measurements)
			post(to: deviceHash,
				 with: mrequest,
				 responseType: .CSV,
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
		if let deviceHash = model.sharing.userHash {
			let del_request = DeleteRequest(password: Model.shared.sharing.password ?? "")
			delete(to: deviceHash,
				   with: del_request,
				   done: done)
		} else {
			logger.error("no device Hash")
		}
	}
	
	public func moveHash(old: String, new: String, done: @escaping (Result<[[String]]>) -> Void){
		let moveRequest = MoveRequest(password: Model.shared.sharing.password ?? "",
									  old_password: Model.shared.sharing.password ?? "",
									  old_hash: old)
		post(to: new,
			 with: moveRequest,
			 responseType: .CSV,
			 done: {(res: Result<[[String]]>) in
				if res.isSuccess, let value = res.value {
					self.parseToDataset(value)
				}
				done(res)
		})
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
