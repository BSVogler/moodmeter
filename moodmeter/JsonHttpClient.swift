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


// MARK: - JsonHttpClient
class JsonHttpClient {
    // MARK: Stored Instance Properties
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let baseUrl: String
    private let loggerPrefixLength = 150
    
    // MARK: Initializers
    init(_ baseUrl: String) {
        self.baseUrl = baseUrl
    }

    // MARK: Instance Methods
	//with is a codable (serializable) class or struct
    func post<TData: Encodable, TResponse: Decodable>(
        to endpoint: String,
        with data: TData,
        whichHasType dataType: TData.Type,
        expecting responseType: TResponse.Type,
        done: @escaping (Result<TResponse>) -> Void
    ) {
        request(using: .post, to: endpoint, with: data, done: done)
    }

    func put<TData: Encodable, TResponse: Decodable>(
        to endpoint: String,
        with data: TData,
        whichHasType dataType: TData.Type,
        expecting responseType: TResponse.Type,
        done: @escaping (Result<TResponse>) -> Void
    ) {
        request(using: .put, to: endpoint, with: data, done: done)
    }

    func delete<TResponse: Decodable>(
        to endpoint: String,
        expecting responseType: TResponse.Type,
        done: @escaping (Result<TResponse>) -> Void
    ) {
        request(using: .delete, to: endpoint, with: nil as String?, done: done)
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
        done: @escaping (Result<TResponse>) -> Void
        ) {
        guard let url = URL(string: baseUrl + endpoint) else {
			logger.error("Url invalid.")
            done(.failure(ApiError.fetchError))
            return
        }

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
            
            self.decodeAndPropagate(data: data, done: done)
        }
        
    }
    
    private func decodeAndPropagate<TResponse: Decodable>(data: Data, done: @escaping (Result<TResponse>) -> Void) {
        
        var decodedResult: ApiResponse<TResponse>?
        do {
            decodedResult = try self.decoder.decode(ApiResponse<TResponse>.self, from: data)
        } catch let error {
            logger.warning("Could not parse result.")
            done(.failure(ApiError.parseError(message: String(describing: error))))
            return
        }
        
        if let result = decodedResult, result.status == "ok", let resultData = result.data {
            done(.success(resultData))
            return
        }
        
        if let result = decodedResult, let error = result.error {
            logger.debug("Result encoded but encountered error: \(error)")
            done(.failure(ApiError.errorMessage(message: error)))
            return
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

class MoodAPIjsonHttpClient: JsonHttpClient {
	let model: Model
	
	init(model: Model) {
		self.model = model
		super.init(model.sharingURL)
	}
	func post<TData: Encodable, TResponse: Decodable>(
		with data: TData,
		whichHasType dataType: TData.Type,
		expecting responseType: TResponse.Type,
		done: @escaping (Result<TResponse>) -> Void
		) {
		if let deviceHash = model.deviceHash {
			super.request(using: .post, to: deviceHash, with: data, done: done)
		} else {
			logger.error("no device Hash")
		}
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
}
