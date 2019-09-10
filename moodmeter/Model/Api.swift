//
//  ApyType.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

// MARK: - ApiResponse
struct ApiResponse<T: Decodable>: Decodable {
	// MARK: Stored Instance Properties
	let data: T?
	let error: String?
	let status: String
}

// MARK: - ApiRequest
struct ApiRequest<T: Encodable>: Encodable {
	// MARK: Stored Instance Properties
	let data: T
}

typealias Mood = Int

protocol AuthorizedRequest: Codable {
	var password: String { get }
}

struct MeasurementRequest: AuthorizedRequest  {
	let password: String
	let measurements: [Measurement]
}

struct DeleteRequest: AuthorizedRequest  {
	var password: String
}



func dateToJSTime(date: Date) -> String {
	let dateFormatter = DateFormatter()
	let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
	dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
	dateFormatter.locale = NSLocale.current
	dateFormatter.dateFormat = "yyyy-MM-dd'T'" //JS format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
	let strDate = dateFormatter.string(from: date)
	return strDate
}
