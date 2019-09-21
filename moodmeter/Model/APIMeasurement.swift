//
//  Measurement.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 06.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation

//struct to parse data from the api
struct APIMeasurement: Codable {
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
	
	func toMeasurement() -> Measurement? {
		if let date = Date.fromJS(from: day) {
			return Measurement(day: date, mood: mood)
		} else {
			return nil
		}
	}
}