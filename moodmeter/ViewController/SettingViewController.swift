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
	
	@IBAction func pushSwitch(_ sender: Any) {
		if notification.isOn {
			registerForPushNotifications()
		}
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
