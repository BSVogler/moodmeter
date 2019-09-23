//
//  CSVDecoder.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 23.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

class CSVDecoder {
	open func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
		guard let data = String(bytes: data, encoding: .utf8) else {
			throw ApiError.parseError(message: "could not cast to string")
		}
		var array = data.components(separatedBy: "\n")
		array = array.dropLast()
		let csvsplit = array.map { $0.components(separatedBy: ";") }
		let apiresponse = ApiResponse(data: csvsplit, error: nil, status: "ok")
		return apiresponse as! T
	}
}
