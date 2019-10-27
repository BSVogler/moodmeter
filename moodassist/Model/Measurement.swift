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
class Measurement: Codable, Comparable {
    
    // MARK: Stored Type Properties
	static var moodToText: [String] = ["?", ":-(", ":-/", ":-|", ":-)", ":-D"]
	static var moodToColor: [UIColor] = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.8156862745, green: 0.368627451, blue: 0.537254902, alpha: 1), #colorLiteral(red: 0.6980392157, green: 0.6078431373, blue: 0.968627451, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5333333333, green: 1, blue: 0.2784313725, alpha: 1), #colorLiteral(red: 1, green: 0.8941176471, blue: 0.1490196078, alpha: 1)]
	static let changedNotification = Notification.Name("measurementsChanged")
	static let erasedNotification = Notification.Name("erasedDataset")
	static var dateFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
		dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "yyyy-MM-dd'T'" //JS format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
		return dateFormatter
	}
    
    // MARK: Stored Instance Properties
    var mood: Mood
	var day: Date {
		didSet{
			day = day.normalized()
		}
	}//without hours and minutes
    
	//Mark: computed property
	var isYesterday: Bool {
		return day == Date.yesterday()
	}
    
	// MARK: Initializers
	init() {
		self.day = Date.today()
		self.mood = 0
	}
	
	init(day: Date, mood: Mood){
		self.day = day
		self.mood = mood
	}
	
	init(day: String, mood: Mood){
		self.day = Date.fromJS(day) ?? Date.today()
		self.mood = mood
	}
	
	// MARK: Instance Methods
	/// call this function to trigger saving and posting of the change
	func moodChanged(){
		//async because this is not so time critical
		DispatchQueue.main.async {
			_ = Model.shared.saveToFiles()
			MoodApiJsonHttpClient.shared.postMeasurementWithoutConfirm(measurements: [self])
		}
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
	
	static func < (lhs: Measurement, rhs: Measurement) -> Bool {
		return lhs.day < rhs.day
	}
	
	static func == (lhs: Measurement, rhs: Measurement) -> Bool {
		return lhs.day == rhs.day
	}
}
