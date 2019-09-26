//
//  Reminder.swift
//  moodmeter
//
//  Created by Lukas Gerhardt on 22.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - Reminder
struct Reminder: Codable {
    
    // MARK: Stored Instance Properties
    var isEnabled = false
    var hour = 22
    var minute = 00
}
