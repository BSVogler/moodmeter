//
//  ReminderInterfaceController.swift
//  Moodtracker WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 26.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import WatchKit
import UserNotifications

// MARK: - ReminderInterfaceController
class ReminderInterfaceController: WKInterfaceController {
	
    // MARK: Private Instance Methods
    let reminder = DataHandler.userProfile.reminder // just for code convenience
    
    // MARK: IBOutlets
	@IBOutlet private weak var notificationSwitch: WKInterfaceSwitch!
	@IBOutlet private weak var reminderTimePicker: WKInterfaceGroup!
	@IBOutlet private weak var hourPicker: WKInterfacePicker!
	@IBOutlet private weak var minutePicker: WKInterfacePicker!
	
    // MARK: Initializers
    override init() {
        super.init()
        let reminder = DataHandler.userProfile.reminder
        notificationSwitch.setOn(reminder.isEnabled)
        //disable if is not authorized
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if(settings.authorizationStatus != .authorized) {
                //ui updates must be performed in main thread
                DispatchQueue.main.async {
                    self.setEnabled(false)
                }
            }
        }
        
        reminderTimePicker.setHidden(reminder.isEnabled)
        let hours = (0...23).map{ value -> WKPickerItem in
            let item = WKPickerItem()
            item.title = String(value)
            return item
        }
        hourPicker.setItems(hours)
        hourPicker.setSelectedItemIndex(reminder.hour)
        let minutes = (0...59).map{ value -> WKPickerItem in
            let item = WKPickerItem()
            item.title = String(value)
            return item
        }
        minutePicker.setItems(minutes)
        minutePicker.setSelectedItemIndex(reminder.minute)
    }
    
    // MARK: Deinitializers
    deinit {
        _ = DataHandler.saveToFiles()
        if reminder.isEnabled {
            Notifications.registerNotification()
        }
    }
    
    // MARK: IBActions
	@IBAction func pushReminderSwitch(_ value: Bool) {
		setEnabled(value)
	}
	
	@IBAction func hourChanged(_ value: Int) {
        if reminder.isEnabled {
            DataHandler.userProfile.reminder.hour = value
		}
	}
	
	@IBAction func minuteChanged(_ value: Int) {
		if reminder.isEnabled {
            DataHandler.userProfile.reminder.minute = value
		}
	}
	
    // MARK: Instance Methods
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
        DataHandler.userProfile.reminder.isEnabled = enabled
		self.notificationSwitch.setOn(enabled)
		self.reminderTimePicker.setHidden(enabled)
        _ = DataHandler.saveToFiles()
	}
	

}
