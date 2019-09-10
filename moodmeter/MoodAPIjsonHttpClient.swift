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
		super.init(model.sharingURL)
	}
	
	public func postMeasurement(measurements: [Measurement]){
		if let deviceHash = model.deviceHash {
			var password = "todo"
			let mrequest = MeasurementRequest(password: password, measurements: measurements)
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
			var password = "todo"
			let del_request = DeleteRequest(password: password)
			post(to: deviceHash,
				   with: del_request,
				   whichHasType: DeleteRequest.self,
				   expecting: DeleteRequest.self) {res in
			}
		} else {
			logger.error("no device Hash")
		}
	}
}
