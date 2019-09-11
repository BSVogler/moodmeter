//
//  SettingViewController.swift
//  Moodmeter
//
//  Created by Benedikt Stefan Vogler on 08.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit
import UserNotifications

class SettingViewController: UIViewController {
	
	@IBOutlet weak var reminderTimePicker: UIDatePicker!
	@IBOutlet weak var notification: UISwitch!
	@IBOutlet weak var timeLabel: UILabel!
	
	@IBAction func eraseButton(_ sender: Any) {
		confirm(title: "Delete?", message: "Delete all locally saved data?") { action in
			if Model.shared.eraseData() {
				self.alert(title:"Deleting", message: "Deleted all data")
			} else {
				self.alert(title:"Deleting", message: "Deleting of all data not possible")
			}
		}
	}
	
	@IBAction func timeChanced(_ sender: Any) {
		let content = UNMutableNotificationContent()
		content.title = "Mood Time"
		content.body = "It is time to give me your mood."
		
		// Configure the recurring date.
		var dateComponents = DateComponents()
		dateComponents.calendar = Calendar.current

		let hourOfTheDay = dateComponents.calendar?.component(Calendar.Component.hour, from: reminderTimePicker.date)
		dateComponents.hour = hourOfTheDay
		
		let minuteOfTheDay = dateComponents.calendar?.component(Calendar.Component.minute, from: reminderTimePicker.date)
		dateComponents.minute = minuteOfTheDay
		
		// Create the trigger as a repeating event.
		let trigger = UNCalendarNotificationTrigger(
			dateMatching: dateComponents, repeats: true)
		
		// Create the request
		let uuidString = UUID().uuidString
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
	
	@IBAction func pushSwitch(_ sender: Any) {
		if notification.isOn {
			registerForPushNotifications()
			timeChanced(sender)
		}
		reminderTimePicker.isHidden = !notification.isOn
		timeLabel.isHidden = !notification.isOn
	}
	
	// Mark: - Initializer
	convenience init() {
		self.init(nibName:nil, bundle:nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	func registerForPushNotifications() {
	  UNUserNotificationCenter.current() // 1
		.requestAuthorization(options: [.alert, .sound, .badge]) { // 2
		  granted, error in
		  print("Permission granted: \(granted)") // 3
	  }
	}
	
}
