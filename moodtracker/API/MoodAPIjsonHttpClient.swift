//
//  MoodAPI.swift
//  Moodmeter
//
//  Created by Benedikt Stefan Vogler on 10.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import Alamofire

class MoodAPIjsonHttpClient: JsonHttpClient {
	let model: Model
	public static let shared = MoodAPIjsonHttpClient(model: Model.shared)
	
	init(model: Model) {
		self.model = model
		super.init(model.baseURL)
	}
	
	public func postMeasurement(measurements: [APIMeasurement], done: @escaping (Result<[[String]]>) -> Void){
		if let deviceHash = model.userHash {
			let mrequest = MeasurementRequest(password: Model.shared.password ?? "",
											  measurements: measurements)
			post(to: deviceHash,
				 with: mrequest,
				 responseType: .CSV,
				 done: {(res: Result<[[String]]>) in
					if res.isSuccess, let value = res.value {
						for item in value {
							guard let date = Date.fromJS(item[0]) else {
								print("could not parse string (\(item[0])) to Date")
								continue
							}
							
							Model.shared.dataset[date] = Int(item[1])
						}
					}
					
					done(res)
			})
		} else {
			logger.error("no device Hash")
		}
	}
	
	public func delete(done: @escaping (Result<DeleteRequest>) -> Void){
		if let deviceHash = model.userHash {
			let del_request = DeleteRequest(password: Model.shared.password ?? "")
			delete(to: deviceHash,
				   with: del_request,
				   expecting: DeleteRequest.self, done: done)
		} else {
			logger.error("no device Hash")
		}
	}
	
	typealias Dataset = [Date: Mood]
	public func moveHash(old: String, new: String, done: @escaping (Result<Dataset>) -> Void){
		let moveRequest = MoveRequest(password: Model.shared.password ?? "",
									  old_password: Model.shared.password ?? "",
									  old_hash: old)
		post(to: new,
			 with: moveRequest,
			 responseType: .CSV,
			 done: {(res: Result<Dataset>) in
				if res.isSuccess, let dataset = res.value {
					Model.shared.dataset = dataset
				}
				
				done(res)
		})
	}
}
