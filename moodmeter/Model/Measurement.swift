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
		self.day = dateToJSTime(date: day)
		self.mood = mood
	}
}
