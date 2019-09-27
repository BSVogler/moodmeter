//
//  ReminderInterfaceController.swift
//  Moodtracker WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import WatchKit
import UserNotifications

class ReminderInterfaceController: WKInterfaceController {
	
	@IBOutlet private weak var notificationSwitch: WKInterfaceSwitch!
	
	@IBOutlet weak var reminderTimePicker: WKInterfaceGroup!
	@IBOutlet weak var hourPicker: WKInterfacePicker!
	@IBOutlet weak var minutePicker: WKInterfacePicker!
	
	@IBAction func pushReminderSwitch(_ value: Bool) {
		setEnabled(value)
	}
	
	@IBAction func hourChanged(_ value: Int) {
		if Model.shared.reminderEnabled {
			Model.shared.reminderHour = value
		}
	}
	
	@IBAction func minuteChanged(_ value: Int) {
		if Model.shared.reminderEnabled {
			Model.shared.reminderMinute = value
		}
	}
	
	override init() {
		super.init()
		notificationSwitch.setOn(Model.shared.reminderEnabled)
		//disable if is not authorized
		UNUserNotificationCenter.current().getNotificationSettings { (settings) in
			if(settings.authorizationStatus != .authorized) {
				//ui updates must be performed in main thread
				DispatchQueue.main.async {
					self.setEnabled(false)
				}
			}
		}
		
		reminderTimePicker.setHidden(!Model.shared.reminderEnabled)
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
	
	func setEnabled(_ enabled: Bool){
		if enabled {
			Notifications.registerNotificationRights()
			Notifications.registerNotification()
			//temporaryugly fix for #11
			UNUserNotificationCenter.current().getNotificationSettings { (settings) in
				if(settings.authorizationStatus != .authorized) {
					//ui updates must be performed in main thread
					DispatchQueue.main.async {
						self.presentAlert(withTitle: NSLocalizedString("No rights", comment: ""), message: NSLocalizedString("Please enable notifications for this app in your system settings.", comment: ""), preferredStyle: .actionSheet, actions: [ WKAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) {}])
						self.setEnabled(false)
					}
				}
			}
		}
		Model.shared.reminderEnabled = enabled
		self.notificationSwitch.setOn(Model.shared.reminderEnabled)
		self.reminderTimePicker.setHidden(!Model.shared.reminderEnabled)
		_ = Model.shared.saveToFiles()
	}
	
	// MARK: Deinitializer
	deinit {
		_ = Model.shared.saveToFiles()
		if Model.shared.reminderEnabled {
			Notifications.registerNotification()
		}
	}
}