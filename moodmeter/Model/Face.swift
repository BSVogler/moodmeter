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
	
	var _mood: Mood = 0
	var mood: Mood {
		set {
			if newValue != _mood {
				_mood = newValue
				moodChanged()
			}
		}
		get {return _mood}
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
	
	
	// MARK: Initializers
	init() {
		date = Date()
		if let moodOnDate = Model.shared.dataset[date] {
			mood = moodOnDate
		}
	}
	
	// MARK: functions
	func moodChanged(){
		Model.shared.dataset[date] = mood
		_ = Model.shared.saveToFiles()
		MoodAPIjsonHttpClient.shared.postMeasurement(measurements: [Measurement(day: Date(), mood: mood)]){res in
		}
	}
	
	func setToYesterday(){
		isYesterday = true
		date = yesterday ?? date
	}
	
	func getSmiley() -> String {
		return Face.moodToText[mood]
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
			Face.moodToColor[mood].getHue(hueP, saturation: saturationP, brightness: brightnessP, alpha: alphaP)
			return UIColor(hue: hue, saturation: saturation, brightness: brightness*0.7, alpha: alpha)
		}
		return Face.moodToColor[mood]
	}
	
}
