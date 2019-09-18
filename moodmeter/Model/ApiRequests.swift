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

struct MoveRequest: AuthorizedRequest  {
	var password: String
	var old_hash: String
}

