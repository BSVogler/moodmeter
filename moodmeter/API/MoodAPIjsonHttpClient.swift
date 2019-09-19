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
	
	public func postMeasurement(measurements: [Measurement], done: @escaping (Result<MeasurementRequest>) -> Void){
		if let deviceHash = model.userHash {
			let mrequest = MeasurementRequest(password: Model.shared.password ?? "",
											  measurements: measurements)
			post(to: deviceHash,
				 with: mrequest,
				 expecting: MeasurementRequest.self, done: done)
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
	
	public func moveHash(old: String, new: String, done: @escaping (Result<MoveRequest>) -> Void){
		let moveRequest = MoveRequest(password: Model.shared.password ?? "",
									  old_password: Model.shared.password ?? "",
									old_hash: old)
		post(to: new,
			 with: moveRequest,
			 expecting: MoveRequest.self,
			 done: done)
	}
}
