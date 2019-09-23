//
//  JsonHttpClient.swift
//  iHaus
//
//  Created by Michael Neu on 01.06.19.
//  Copyright © 2019 TUM. All rights reserved.
//

// MARK: Imports
import Foundation
import Alamofire
import SwiftyBeaver

let logger = SwiftyBeaver.self

enum ResponseType {
	case JSON
	case CSV
}

// MARK: - JsonHttpClient
class JsonHttpClient {
	// MARK: Stored Instance Properties
	private let decoder = JSONDecoder()
	private let encoder = JSONEncoder()
	private let csvdecoder = CSVDecoder()
	private let baseUrl: URL
	private let loggerPrefixLength = 150
	
	// MARK: Initializers
	init(_ baseUrl: URL) {
		self.baseUrl = baseUrl
	}
	
	// MARK: Instance Methods
	//with is a codable (serializable) class or struct
	func post<TData: Encodable, TResponse: Decodable>(
		to endpoint: String,
		with data: TData,
		responseType: ResponseType = .JSON,
		done: @escaping (Result<TResponse>) -> Void
	) {
		request(using: .post, to: endpoint, with: data, responseType: responseType, done: done)
	}
	
	func put<TData: Encodable, TResponse: Decodable>(
		to endpoint: String,
		with data: TData,
		expecting responseType: TResponse.Type,
		done: @escaping (Result<TResponse>) -> Void
	) {
		request(using: .put, to: endpoint, with: data, done: done)
	}
	
	func delete<TData: Encodable, TResponse: Decodable>(
		to endpoint: String,
		with data: TData,
		done: @escaping (Result<TResponse>) -> Void
	) {
		request(using: .delete, to: endpoint, with: data, done: done)
	}
	
	func get<TResponse: Decodable>(
		to endpoint: String,
		expecting responseType: TResponse.Type,
		done: @escaping (Result<TResponse>) -> Void
	) {
		request(using: .get, to: endpoint, with: nil as String?, done: done)
	}
	
	// MARK: Private Instance Methods
	fileprivate func request<TData: Encodable, TResponse: Decodable>(
		using method: HTTPMethod,
		to endpoint: String,
		with body: TData?,
		responseType: ResponseType = .JSON,
		done: @escaping (Result<TResponse>) -> Void
	) {
		let url = baseUrl.appendingPathComponent(endpoint)
		
		var request = URLRequest(url: url)
		request.httpMethod = String(describing: method)
		
		if let body = body {
			let wrappedBody = ApiRequest(data: body)
			guard let json = try? encoder.encode(wrappedBody) else {
				done(.failure(ApiError.serializeError))
				return
			}
			
			request.httpBody = json
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		}
		
		logger.verbose("Making \(method) request to \(url) with body \(String(describing: body))")
		Alamofire.request(request).responseData { response in
			
			guard let data = response.data else {
				logger.warning("No response data returned.")
				done(.failure(ApiError.fetchError))
				return
			}
			self.logResponse(for: data)
			
			if let error = response.result.error {
				logger.debug("Error returned: \(error)")
				done(.failure(error))
				return
			}
			
			if let statuscode = response.response?.statusCode,
				statuscode == 404 {
				logger.warning("404, not found")
				done(.failure(ApiError.errorMessage(message: "API not found. 404")))
				return
			}
			
			self.decodeAndPropagate(data: data, responseType: responseType, done: done)
		}
	}
	
	private func decodeAndPropagate<TResponse: Decodable>(data: Data, responseType: ResponseType = .JSON, done: @escaping (Result<TResponse>) -> Void) {
		var decodedResult: ApiResponse<TResponse>?
		do {
			if responseType == .JSON {
				decodedResult = try self.decoder.decode(ApiResponse<TResponse>.self, from: data)
			} else {
				decodedResult = try self.csvdecoder.decode(ApiResponse<TResponse>.self, from: data)
			}
		} catch let error {
			logger.warning("Could not parse result.")
			done(.failure(ApiError.parseError(message: String(describing: error))))
			return
		}
		if let result = decodedResult {
			if result.status == "ok", let resultData = result.data {
				done(.success(resultData))
				return
			}
			if let error = result.error {
				logger.debug("Result encoded but encountered error: \(error)")
				done(.failure(ApiError.errorMessage(message: error)))
				return
			}
		}
	}

	private func logResponse(for data: Data) {
		let response = ("Response: \(String(data: data, encoding: .utf8) ?? "Response data not decodable.")")
		
		var responsePrefix = response.prefix(loggerPrefixLength)
		if response.count > loggerPrefixLength {
			responsePrefix += (" [+\(response.count - loggerPrefixLength) chars]")
		}
		logger.verbose(responsePrefix)
	}
	
}
