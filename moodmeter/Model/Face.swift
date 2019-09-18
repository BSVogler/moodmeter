//
//  Face.swift
//  moodmeter
//
//  Created by Benedikt Stefan Vogler on 17.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import UIKit.UIColor

class Face {
	static var moodToText: [String] = ["?", ":-(", ":-/", ":-|", ":-)", ":-D"]
	static var moodToColor: [UIColor] = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.6324028457, green: 0.5172401532, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5333333333, green: 1, blue: 0.2784313725, alpha: 1), #colorLiteral(red: 1, green: 0.8941176471, blue: 0.1490196078, alpha: 1)]
	
	// MARK: Class
	static func getSmiley(mood: Mood) -> String {
		return moodToText[mood]
	}
	
	static func getColor(mood: Mood) -> UIColor {
		return moodToColor[mood]
	}
	
	
	// MARK: Computed properties
	var date: Date {
		set {
			let calendar = Calendar.current
			dateWithoutHours = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: newValue)!
		}
		get {return dateWithoutHours}
	}
	var yesterday: Date? {
		let calendar = Calendar.current
		return calendar.date(byAdding: .day, value: -1, to: Date())
	}
	
	var mood: Mood {
		set {
			_mood = newValue
			moodChanged()
		}
		get {return _mood}
	}
	
	var isYesterday: Bool {
		set {
			_isYesterday = newValue
			if newValue {
				date = yesterday ?? date
			} else {
				date = Date()
			}
		}
		get {return _isYesterday}
	}
	
	// MARK: Stored properties
	private var _mood: Mood = 0
	private var _isYesterday = false
	
	private var dateWithoutHours: Date = Date()
	
	
	// MARK: Initializers
	init(){
		date = Date()
	}
	
	// MARK: functions
	func moodChanged(){
		Model.shared.dataset[date] = mood
		MoodAPIjsonHttpClient.shared.postMeasurement(measurements: [Measurement(day: Date(), mood: mood)]){res in
		}
	}
	
	func setToYesterday(){
		isYesterday = true
		date = yesterday ?? date
	}
}