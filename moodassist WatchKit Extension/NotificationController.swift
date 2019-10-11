//
//  NotificationController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications


class NotificationController: WKUserNotificationInterfaceController {

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
	@IBAction func veryGood() {
		Model.shared.getMeasurement(at: Date())?.mood = 5
	}
	@IBAction func good() {
		Model.shared.getMeasurement(at: Date())?.mood = 4
	}
	@IBAction func okay() {
		Model.shared.getMeasurement(at: Date())?.mood = 3
	}
	@IBAction func meh() {
		Model.shared.getMeasurement(at: Date())?.mood = 2
	}
	@IBAction func bad() {
		Model.shared.getMeasurement(at: Date())?.mood = 1
	}
}
