//
//  Measurement.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 17.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit.UIColor

// MARK: - Measurement
class Measurement: Codable {
    
    // MARK: Stored Instance Properties
    /// Sends update to server when changed (didSet is not being called on initialization)
    var mood: Mood {
        didSet {
            MoodApiJsonHttpClient.shared.postMeasurement(measurements: self) { _ in }
        }
    }
    var day: Date
    
	// MARK: Initializers
	init(day: Date, mood: Mood) {
        self.day = day.normalized()
		self.mood = mood
	}
	
    /// initializes a `Measurement` with a date-formatted String (e.g. returned by API)
	init(day: String, mood: Mood) {
        if let date = Date.fromJS(day) {
            self.day = date.normalized()
        }
		self.mood = mood
	}
	
	// MARK: Instance Methods
    func getSmiley() -> String {
		return Mood.moodToText[mood]
	}
	
	func getColor() -> UIColor {
		if isFromYesterday() {
			var hue: CGFloat = 0.0
			let hueP = UnsafeMutablePointer<CGFloat>(&hue)
			var saturation: CGFloat = 0.0
			let saturationP = UnsafeMutablePointer<CGFloat>(&saturation)
			var brightness: CGFloat = 0.0
			let brightnessP = UnsafeMutablePointer<CGFloat>(&brightness)
			var alpha: CGFloat = 0.0
			let alphaP = UnsafeMutablePointer<CGFloat>(&alpha)
			Mood.moodToColor[mood].getHue(hueP, saturation: saturationP, brightness: brightnessP, alpha: alphaP)
			return UIColor(hue: hue, saturation: saturation, brightness: brightness*0.7, alpha: alpha)
		}
		return Mood.moodToColor[mood]
	}
    
    // MARK: Private Instance Methods
    /// returns true, when this instance's date equals yesterday's date
    private func isFromYesterday() -> Bool {
        return self.day == Date.yesterday
    }
}
