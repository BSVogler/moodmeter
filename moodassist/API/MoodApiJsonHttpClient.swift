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
		super.init(model.sharing.apiURL)
		super.jsonDecoder.dateDecodingStrategy = .formatted(Measurement.dateFormatter)
		super.jsonEncoder.dateEncodingStrategy = .formatted(Measurement.dateFormatter)
	}
	
    // MARK: Instance Methods
	///parses csv data with format date;mood (item[0];item[1])
	public func parseToDataset(_ input: [[String]]){
		var newItems: [Measurement] = []
		for item in input {
			if let date = Date.fromJS(item[0]),
				let mood = Int(item[1]) {
				newItems.append(Measurement(day: date, mood: mood))
			}
		}
		newItems = newItems.sorted { $0.day < $1.day }
		model.addMeasurment(newItems)
	}
	
	public func register(measurements: [Measurement], done: @escaping (Result<RegisterResponse>) -> Void){
		let mrequest = MeasurementRequest(password: Model.shared.sharing.password ?? "",
										  measurements: measurements)
		request(using: .post,
				to:  "/register/",
				with: mrequest,
				responseType: .json,
				done: done
		)
	}
	
	public func moveHash(old: String, done: @escaping (Result<RegisterResponse>) -> Void){
		let moveRequest = MoveRequest(password: Model.shared.sharing.password ?? "",
									  old_password: Model.shared.sharing.password ?? "",
									  old_hash: old)
		request(using: .post,
				to: "/register/",
				with: moveRequest,
				responseType: .json,
				done: done
		)
	}
	
	public func importHash(old: String, new: String, done: @escaping (Result<[[String]]>) -> Void){
		let moveRequest = MoveRequest(password: Model.shared.sharing.password ?? "",
									  old_password: Model.shared.sharing.password ?? "",
									  old_hash: old)
		request(using: .post, to: new, with: moveRequest, responseType: .csv, done: {(res: Result<[[String]]>) in
			if res.isSuccess, let value = res.value {
				self.parseToDataset(value)
			}
			done(res)
		})
	}
	
	/// post the data without parsing the result
	public func postMeasurementWithoutConfirm(measurements: [Measurement]){
		if let deviceHash = model.sharing.userHash {
			let mrequest = MeasurementRequest(password: Model.shared.sharing.password ?? "",
											  measurements: measurements)
			request(using: .post, to: deviceHash, with: mrequest, responseType: .csv){(res: Result<[[String]]>) in}
			//let conf = URLSessionConfiguration()
			//let session = URLSession.init(configuration: conf)
			//let task = session.dataTask(with: url)
			//task.resume()
		} else {
			logger.error("no device Hash")
		}
	}
	
	public func postMeasurement(measurements: [Measurement], done: @escaping (Result<[[String]]>) -> Void){
		if let deviceHash = model.sharing.userHash {
			let mrequest = MeasurementRequest(password: Model.shared.sharing.password ?? "",
											  measurements: measurements)
			request(using: .post,
					to: deviceHash,
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
		if let deviceHash = model.sharing.userHash {
			let del_request = DeleteRequest(password: Model.shared.sharing.password ?? "")
			request(using: .delete,
					to:  deviceHash,
					with: del_request,
					done: done)
		} else {
			logger.error("no device Hash")
		}
	}
	
	public func getData(hash: String, done: @escaping (Result<[[String]]>) -> Void){
		request(using: .get,
				to:  hash,
				with: nil as String?,
				done: {(res: Result<[[String]]>) in
					if res.isSuccess, let value = res.value {
						self.parseToDataset(value)
					}
					done(res)
		})
	}
}
