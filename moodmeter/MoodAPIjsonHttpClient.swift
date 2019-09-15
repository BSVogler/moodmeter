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
	
	public func postMeasurement(measurements: [Measurement]){
		if let deviceHash = model.deviceHash {
			let mrequest = MeasurementRequest(password: Model.shared.password ?? "",
											  measurements: measurements)
			post(to: deviceHash,
				 with: mrequest,
				 whichHasType: MeasurementRequest.self,
				 expecting: MeasurementRequest.self) {res in
			}
		} else {
			logger.error("no device Hash")
		}
	}
	
	public func delete(){
		if let deviceHash = model.deviceHash {
			let del_request = DeleteRequest(password: Model.shared.password ?? "")
			post(to: deviceHash,
				 with: del_request,
				 whichHasType: DeleteRequest.self,
				 expecting: DeleteRequest.self) {res in
			}
		} else {
			logger.error("no device Hash")
		}
	}
	
	public func moveHash(old: String){
		if let deviceHash = model.deviceHash {
			let moveRequest = MoveRequest(password: Model.shared.password ?? "", old_hash: old)
			post(to: deviceHash,
				 with: moveRequest,
				 whichHasType: MoveRequest.self,
				 expecting: MoveRequest.self) {res in
			}
		} else {
			logger.error("no device Hash")
		}
	}
}
