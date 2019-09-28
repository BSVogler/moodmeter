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

// MARK: - Mood
typealias Mood = Int

// MARK: - Measurement
class Measurement: Codable {
    
    // MARK: Stored Type Properties
    static let changedNotification = Notification.Name("measurementsChanged")
    // MARK: Stored Instance Properties
    /// Sends update to server when changed (didSet is not being called on initialization)
    var mood: Mood {
        didSet {
            _ = DataHandler.saveToFiles()
            MoodApiJsonHttpClient.shared.postMeasurement(measurements: [self]) { _ in }
        }
    }
    var day: Date {
        didSet {
            self.day = self.day.normalized()
        }
    }
    
	// MARK: Initializers
    init() {
        let today = Date().normalized()
        self.day = today
        if let exisitingMsmt = DataHandler.userProfile.dataset.first(where: { $0.day == today }) {
            self.mood = exisitingMsmt.mood
        } else {
            self.mood = 0
        }
    }
    
	init(day: Date, mood: Mood) {
        self.day = day.normalized()
		self.mood = mood
	}
	
    /// initializes a `Measurement` with a date-formatted String (e.g. returned by API)
	init(day: String, mood: Mood) {
        if let date = Date.fromJS(day) {
            self.day = date.normalized()
        } else {
            self.day = Date().normalized()
        }
		self.mood = mood
	}
	
	// MARK: Instance Methods
    func getSmiley() -> String {
		return MoodConstants.moodToText[mood]
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
			MoodConstants.moodToColor[mood].getHue(hueP, saturation: saturationP, brightness: brightnessP, alpha: alphaP)
			return UIColor(hue: hue, saturation: saturation, brightness: brightness*0.7, alpha: alpha)
		}
		return MoodConstants.moodToColor[mood]
	}
    
    /// returns true, when this instance's date equals yesterday's date
    func isFromYesterday() -> Bool {
        return self.day == Date.yesterday
    }
}
