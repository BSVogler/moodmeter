//
//  SettingViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 08.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import UIKit
import UserNotifications

// MARK: - SettingViewController
class SettingViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet private weak var reminderTimePicker: UIDatePicker!
	@IBOutlet private weak var notificationSwitch: UISwitch!
	@IBOutlet private weak var timeLabel: UILabel!
	@IBOutlet private weak var versionstring: UILabel!
	
    // MARK: Initializer
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // MARK: Overridden/ Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

		// disable if is not authorized
		UNUserNotificationCenter.current().getNotificationSettings { (settings) in
			if(settings.authorizationStatus != .authorized) {
				//ui updates msut be performed in main thread
				DispatchQueue.main.async {
					self.setEnabled(false)
				}
			}
		}
		
        self.setEnabled(DataHandler.userProfile.reminder.isEnabled)
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        let date = dateComponents.calendar?.date(bySettingHour: DataHandler.userProfile.reminder.hour,
                                                 minute: DataHandler.userProfile.reminder.minute,
                                                 second: 0,
                                                 of: Date())
        reminderTimePicker.date = date ?? Date()
        
        //Version string
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        versionstring.text = "Version \(versionNumber) (\(buildNumber))"
    }
	
	// MARK: IBActions
	@IBAction func doneButtonPressed(_ sender: Any) {
		//presentingViewController?.removeFromParent()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func eraseButton(_ sender: Any) {
		confirm(title: NSLocalizedString("Delete?",comment: ""), message: NSLocalizedString("Delete all locally saved data?",comment: "")) { action in
            if DataHandler.eraseData() {
				self.alert(title:NSLocalizedString("Deleting",comment: ""), message: NSLocalizedString("Deleted all data",comment: ""))
			} else {
				self.alert(title:NSLocalizedString("Deleting",comment: ""), message: NSLocalizedString("Deleting of all data not possible",comment: ""))
			}
		}
	}

	@IBAction func timeChanced(_ sender: Any) {
		Notifications.registerNotification()
		if sender is UIDatePicker {
			_ = DataHandler.saveToFiles()
		}
	}
	
	@IBAction func pushSwitch(_ sender: Any) {
		setEnabled(notificationSwitch.isOn)
	}
	
	// MARK: Instance Methods
	func setEnabled(_ enabled: Bool){
		if enabled {
			Notifications.registerNotificationRights(){success, error in
				DispatchQueue.main.async {
					if success {
						Model.shared.reminderEnabled = true
						_ = Model.shared.saveToFiles()
						Notifications.registerNotification()
						self.notificationSwitch.setOn(true, animated: false)
						self.reminderTimePicker.isHidden = false
					} else {
						
						self.alert(title: NSLocalizedString("No rights", comment: ""), message: NSLocalizedString("Please enable notifications for Moodassist in your system settings.", comment: ""))
					}
				}
			}
		} else {
			//turn off
			if enabled != Model.shared.reminderEnabled {
				Model.shared.reminderEnabled = false
				_ = Model.shared.saveToFiles()
			}
		}
<<<<<<< HEAD:moodassist/Controller/SettingViewController.swift
		var reminder = DataHandler.userProfile.reminder
        reminder.isEnabled = enabled
		notificationSwitch.setOn(reminder.isEnabled, animated: false)
		reminderTimePicker.isHidden = reminder.isEnabled
		timeLabel.isHidden = reminder.isEnabled
		_ = DataHandler.saveToFiles()
=======
		self.notificationSwitch.setOn(Model.shared.reminderEnabled, animated: false)
		self.reminderTimePicker.isHidden = !Model.shared.reminderEnabled
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/SettingViewController.swift
	}
	
}
