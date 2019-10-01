//
//  NotificationController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import WatchKit
import Foundation
import UserNotifications

// MARK: - NotificationController
class NotificationController: WKUserNotificationInterfaceController {
    
    // MARK: Overridden/ Lifecycle Methods
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceive(_ notification: UNNotification) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
    }
    
    // MARK: IBActions
	@IBAction func veryGood() {
        setTodaysMood(to: 5)
	}
    
	@IBAction func good() {
        setTodaysMood(to: 4)
	}
    
	@IBAction func okay() {
        setTodaysMood(to: 3)
	}
    
	@IBAction func meh() {
        setTodaysMood(to: 2)
	}
    
	@IBAction func bad() {
        setTodaysMood(to: 1)
	}
    
    private func setTodaysMood(to mood: Mood) {
        if let today = Date.today {
            if let exisitingMsmt = DataHandler.userProfile.dataset.first(where: { $0.day == today }) {
                exisitingMsmt.mood = mood
            } else {
                DataHandler.userProfile.dataset.append(Measurement(day: today, mood: mood))
            }
        }
    }
}
