//
//  Profile.swift
//  moodtracker
//
//  Created by Lukas Gerhardt on 22.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - Profile
struct Profile: Codable {
    
    // MARK: Stored Instance Properties
    var sharingHash = SharingHash()
    var reminder = Reminder()
    var dataset: [Measurement] = []
}
