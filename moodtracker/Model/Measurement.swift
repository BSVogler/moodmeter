//
//  Face.swift
//  moodmeter
//
//  Created by Benedikt Stefan Vogler on 17.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import UIKit.UIColor

class Measurement: Codable {
	static var moodToText: [String] = ["?", ":-(", ":-/", ":-|", ":-)", ":-D"]
	static var moodToColor: [UIColor] = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.8156862745, green: 0.368627451, blue: 0.537254902, alpha: 1), #colorLiteral(red: 0.6980392157, green: 0.6078431373, blue: 0.968627451, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5333333333, green: 1, blue: 0.2784313725, alpha: 1), #colorLiteral(red: 1, green: 0.8941176471, blue: 0.1490196078, alpha: 1)]
	
	// MARK: Computed properties
	var date: Date {
		set {
			let calendar = Calendar.current
			dateWithoutHours = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: newValue)!
		}
		get {dateWithoutHours}
	}
	var yesterday: Date? {
		let calendar = Calendar.current
		return calendar.date(byAdding: .day, value: -1, to: Date())
	}
	
	var mood: Mood {
		set {
			if newValue != _mood {
				_mood = newValue
				moodChanged()
			}
		}
		get {_mood}
	}
	
	var isYesterday = false {
		didSet {
			if isYesterday {
				date = yesterday ?? date
			} else {
				date = Date()
			}
		}
	}
	
	// MARK: Stored properties
	private var dateWithoutHours: Date = Date()
	var _mood: Mood = 0
	
	// MARK: Initializers
	init() {
		date = Date()
		if let moodOnDate = Model.shared.dataset[date] {
			mood = moodOnDate
		}
	}
	
	init(day: Date, mood: Mood){
		self.date = day
		self.mood = mood
	}
	
	init(day: String, mood: Mood){
		self.date = Date.fromJS(day) ?? Date()
		self.mood = mood
	}
	
	// MARK: functions
	func moodChanged(){
		Model.shared.dataset[date] = mood
		_ = Model.shared.saveToFiles()
		//send time of measurement
		MoodAPIjsonHttpClient.shared.postMeasurement(measurements: [self]){res in
		}
	}
	
	func setToYesterday(){
		isYesterday = true
		date = yesterday ?? date
	}
	
	func getSmiley() -> String {
		return Measurement.moodToText[mood]
	}
	
	func getColor() -> UIColor {
		if isYesterday{
			var hue: CGFloat = 0.0
			let hueP = UnsafeMutablePointer<CGFloat>(&hue)
			var saturation: CGFloat = 0.0
			let saturationP = UnsafeMutablePointer<CGFloat>(&saturation)
			var brightness: CGFloat = 0.0
			let brightnessP = UnsafeMutablePointer<CGFloat>(&brightness)
			var alpha: CGFloat = 0.0
			let alphaP = UnsafeMutablePointer<CGFloat>(&alpha)
			Measurement.moodToColor[mood].getHue(hueP, saturation: saturationP, brightness: brightnessP, alpha: alphaP)
			return UIColor(hue: hue, saturation: saturation, brightness: brightness*0.7, alpha: alpha)
		}
		return Measurement.moodToColor[mood]
	}
}


// MARK: - Extension Date
extension Date {
	static func fromJS(_ from: String) -> Date? {
		let dateFormatter = DateFormatter()
		let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
		dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "yyyy-MM-dd'T'" //JS format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
		return dateFormatter.date(from: from)
	}
	
	func toJS() -> String {
		let dateFormatter = DateFormatter()
		let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
		dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "yyyy-MM-dd'T'" //JS format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
		let strDate = dateFormatter.string(from: self)
		return strDate
	}
	
}
