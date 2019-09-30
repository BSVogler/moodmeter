//
//  Notifications.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 27.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import UserNotifications

class Notifications {
	static func registerNotification() {
		var dateComponents = DateComponents()
		dateComponents.calendar = Calendar.current
		dateComponents.hour = Model.shared.reminderHour
		dateComponents.minute = Model.shared.reminderMinute
		let content = UNMutableNotificationContent()
		content.badge = 1
		content.title = NSLocalizedString("Mood Time", comment: "")
		content.body = NSLocalizedString("It is time to give me your mood.", comment: "")
		// Create the trigger as a repeating event.
		let trigger = UNCalendarNotificationTrigger(
			dateMatching: dateComponents, repeats: true)
		
		// Create the request
		#if os(watchOS)
			//GH Issue #54
			let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
			let uuidString =  String((0..<16).map{ _ in letters.randomElement()! })
		#else
			let uuidString = UUID().uuidString
		#endif
		let request = UNNotificationRequest(identifier: uuidString,
											content: content, trigger: trigger)
		
		// Schedule the request with the system.
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.removeAllPendingNotificationRequests()
		notificationCenter.add(request) { (error) in
			if error != nil {
				print(error ?? "could not register notification")
			}
		}
	}

	static func registerNotificationRights(completionHandler: @escaping (Bool, Error?) -> Void) {
	  UNUserNotificationCenter.current()
		.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: completionHandler)
	}
}
