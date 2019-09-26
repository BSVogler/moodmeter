//
//  ReminderInterfaceController.swift
//  Moodtracker WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import WatchKit

class ReminderInterfaceController: WKInterfaceController {
	
	@IBOutlet private weak var notificationSwitch: WKInterfaceSwitch!
	
	@IBOutlet weak var reminderTimePicker: WKInterfaceGroup!
	@IBOutlet weak var hourPicker: WKInterfacePicker!
	@IBOutlet weak var minutePicker: WKInterfacePicker!
	
	@IBAction func pushReminderSwitch(_ value: Bool) {
		Model.shared.reminderEnabled = value
		if value {
			registerNotificationRights()
			registerNotification()
		}
		reminderTimePicker.setHidden(!value)
		_ = Model.shared.saveToFiles()
	}
	
	@IBAction func hourChanged(_ value: Int) {
		if Model.shared.reminderEnabled {
			Model.shared.reminderHour = value
			registerNotification()
			_ = Model.shared.saveToFiles()
		}
	}
	
	@IBAction func minuteChanged(_ value: Int) {
		if Model.shared.reminderEnabled {
			Model.shared.reminderMinute = value
			registerNotification()
			_ = Model.shared.saveToFiles()
		}
	}
	
	override init() {
		super.init()
		notificationSwitch.setOn(Model.shared.reminderEnabled)
		let hours = (0...23).map{ value -> WKPickerItem in
			let item = WKPickerItem()
			item.title = String(value)
			return item
		}
		hourPicker.setItems(hours)
		hourPicker.setSelectedItemIndex(Model.shared.reminderHour)
		let minutes = (0...59).map{ value -> WKPickerItem in
			let item = WKPickerItem()
			item.title = String(value)
			return item
		}
		minutePicker.setItems(minutes)
		minutePicker.setSelectedItemIndex(Model.shared.reminderMinute)
	}
	
	// MARK: Instance Methods
	func registerNotification(){
		var dateComponents = DateComponents()
		dateComponents.calendar = Calendar.current
		dateComponents.hour = Model.shared.reminderHour
		dateComponents.minute = Model.shared.reminderMinute
		//		let content = UNMutableNotificationContent()
		//		content.title = NSLocalizedString("Mood Time", comment: "")
		//		content.body = NSLocalizedString("It is time to give me your mood.", comment: "")
		//		// Create the trigger as a repeating event.
		//		let trigger = UNCalendarNotificationTrigger(
		//			dateMatching: dateComponents, repeats: true)
		//
		//		// Create the request
		//		let uuidString = UUID().uuidString
		//		let request = UNNotificationRequest(identifier: uuidString,
		//											content: content, trigger: trigger)
		//
		//		// Schedule the request with the system.
		//		let notificationCenter = UNUserNotificationCenter.current()
		//		notificationCenter.removeAllPendingNotificationRequests()
		//		notificationCenter.add(request) { (error) in
		//			if error != nil {
		//				print(error ?? "could not register notification")
		//			}
		//		}
	}
	
	func registerNotificationRights() {
		//	  UNUserNotificationCenter.current() // 1
		//		.requestAuthorization(options: [.alert, .sound, .badge]) { // 2
		//		  granted, error in
		//		  print("Permission granted: \(granted)") // 3
		//	  }
	}
}
