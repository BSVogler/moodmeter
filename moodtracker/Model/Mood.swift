//
//  Mood.swift
//  Moodtracker
//
//  Created by Lukas Gerhardt on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit

// MARK: - Mood
typealias Mood = Int

extension Mood {
    func getSmiley() -> String {
        return Measurement.moodToText[self]
    }
    
    func getColor() -> UIColor {
        return Measurement.moodToColor[self]
    }
}
