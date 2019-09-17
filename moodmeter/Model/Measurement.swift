//
//  Measurement.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 06.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

struct Measurement: Codable {
	let day: String
	let mood: Mood
	
	init(day: String, mood: Mood){
		self.day = day
		self.mood = mood
	}
	
	init(day: Date, mood: Mood){
		self.day = day.toJS()
		self.mood = mood
	}
}

extension Date {
	func toJS() -> String{
		let dateFormatter = DateFormatter()
		let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
		dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
		dateFormatter.locale = NSLocale.current
		dateFormatter.dateFormat = "yyyy-MM-dd'T'" //JS format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
		let strDate = dateFormatter.string(from: self)
		return strDate
	}
}
