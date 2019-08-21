//
//  ApiError.swift
//  iHaus
//
//  Created by Michael Neu on 01.06.19.
//  Copyright © 2019 TUM. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - ApiError
enum ApiError: Error {
    case serializeError, fetchError
    case parseError(message: String)
    case errorMessage(message: String)
}
