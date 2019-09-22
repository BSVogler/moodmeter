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
	
	// MARK: IBOutlets
	@IBOutlet weak var reminderTimePicker: UIDatePicker!
	@IBOutlet weak var notificationSwitch: UISwitch!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var versionstring: UILabel!
	
	// MARK: IBActions
	
	@IBAction func doneButtonPressed(_ sender: Any) {
		//presentingViewController?.removeFromParent()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func eraseButton(_ sender: Any) {
		confirm(title: NSLocalizedString("Delete?",comment: ""), message: NSLocalizedString("Delete all locally saved data?",comment: "")) { action in
			if Model.shared.eraseData() {
				self.alert(title:NSLocalizedString("Deleting",comment: ""), message: NSLocalizedString("Deleted all data",comment: ""))
			} else {
				self.alert(title:NSLocalizedString("Deleting",comment: ""), message: NSLocalizedString("Deleting of all data not possible",comment: ""))
			}
		}
	}
	

	@IBAction func timeChanced(_ sender: Any) {
		
		// Configure the recurring date.
		var dateComponents = DateComponents()
		dateComponents.calendar = Calendar.current

		let hourOfTheDay = dateComponents.calendar?.component(Calendar.Component.hour, from: reminderTimePicker.date)
		dateComponents.hour = hourOfTheDay
		if let hourOfTheDay = hourOfTheDay {
			Model.shared.reminderHour = hourOfTheDay
		}
		
		let minuteOfTheDay = dateComponents.calendar?.component(Calendar.Component.minute, from: reminderTimePicker.date)
		dateComponents.minute = minuteOfTheDay
		if let minuteOfTheDay = minuteOfTheDay {
			Model.shared.reminderMinute = minuteOfTheDay
		}
		
		registerNotification(dateComponents: dateComponents)
		if sender is UIDatePicker {
			_ = Model.shared.saveToFiles()
		}
	}
	
	@IBAction func pushSwitch(_ sender: Any) {
		if notificationSwitch.isOn {
			registerNotificationRights()
			timeChanced(sender)
		}
		Model.shared.reminderEnabled = notificationSwitch.isOn
		reminderTimePicker.isHidden = !notificationSwitch.isOn
		timeLabel.isHidden = !notificationSwitch.isOn
		_ = Model.shared.saveToFiles()
	}
	
	// MARK: Initializer
	convenience init() {
		self.init(nibName:nil, bundle:nil)
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		notificationSwitch.setOn(Model.shared.reminderEnabled, animated: false)
		Model.shared.reminderEnabled = notificationSwitch.isOn
		reminderTimePicker.isHidden = !notificationSwitch.isOn
		timeLabel.isHidden = !notificationSwitch.isOn
		
		var dateComponents = DateComponents()
		dateComponents.calendar = Calendar.current
		
		let date = dateComponents.calendar?.date(bySettingHour: Model.shared.reminderHour,
												 minute: Model.shared.reminderMinute,
												 second: 0,
												 of: Date())
		reminderTimePicker.date = date ?? Date()
		
		//Version string
		let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
		let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
		versionstring.text = "Version \(versionNumber) (\(buildNumber))"
	}
	
	func registerNotification(dateComponents: DateComponents){
		let content = UNMutableNotificationContent()
		content.title = NSLocalizedString("Mood Time", comment: "")
		content.body = NSLocalizedString("It is time to give me your mood.", comment: "")
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
	
	func registerNotificationRights() {
	  UNUserNotificationCenter.current() // 1
		.requestAuthorization(options: [.alert, .sound, .badge]) { // 2
		  granted, error in
		  print("Permission granted: \(granted)") // 3
	  }
	}
	
}
