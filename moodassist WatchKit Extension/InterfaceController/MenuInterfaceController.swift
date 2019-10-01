//
//  MenInterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 17.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//
import WatchKit
import Foundation

class MyRowController: NSObject {
	@IBOutlet weak var itemLabel: WKInterfaceLabel!
	@IBOutlet weak var itemImage: WKInterfaceImage!
}

class MenuInterfaceController: WKInterfaceController {
	
	@IBOutlet weak var table: WKInterfaceTable!
	
	override func willActivate() {
		
		// Configure interface objects here.
		table.setNumberOfRows(3, withRowType: "menuItem")
		
		let sharing = self.table.rowController(at: 0) as! MyRowController
		sharing.itemImage.setImage(UIImage(systemName: "cloud"))
		sharing.itemLabel.setText(NSLocalizedString("Live sharing", comment: ""))
		
		//let export = self.table.rowController(at: 1) as! MyRowController
		//export.itemImage.setImage(UIImage(systemName: "square.and.arrow.up"))
		//export.itemLabel.setText("Export File")
		
		let reminder = self.table.rowController(at: 1) as! MyRowController
		reminder.itemImage.setImage(UIImage(systemName: "clock"))
		reminder.itemLabel.setText(NSLocalizedString("Reminder", comment: ""))
		
		let item2 = self.table.rowController(at: 2) as! MyRowController
		item2.itemImage.setImage(UIImage(systemName: "delete.right"))
		item2.itemLabel.setText(NSLocalizedString("Delete data", comment: ""))
		item2.itemLabel.setTextColor(#colorLiteral(red: 1, green: 0.4156862745, blue: 0.337254902, alpha: 1))
	}
	override func table(_ table: WKInterfaceTable,
						didSelectRowAt rowIndex: Int){
		switch rowIndex {
		case 0:
			if Model.shared.sharing.userHash == nil {
				let accept = WKAlertAction(title: NSLocalizedString("Accept", comment: ""), style: .default) {
					self.pushController(withName: "Share", context: nil)
				}
				presentAlert(withTitle: NSLocalizedString("Privacy", comment: ""), message: NSLocalizedString("By using the share feature you agree to the privacy agreement. It can be found at ", comment: "")+NSLocalizedString("https://moodassist.cloud/privacy", comment:""), preferredStyle: .actionSheet, actions: [accept])
			} else {
				pushController(withName: "Share", context: nil)
			}
		case 1:
			self.pushController(withName: "Reminder", context: nil)
		case 2:
			let accept = WKAlertAction(title: NSLocalizedString("Yes, delete", comment: ""), style: .destructive) {
				_ = Model.shared.eraseData()
			}
			presentAlert(withTitle: NSLocalizedString("Delete data?", comment: ""), message: NSLocalizedString("This will permanently delete your local data on your watch and phone.", comment: ""), preferredStyle: .actionSheet, actions: [ accept])
			
		default: print(NSLocalizedString("export not supported", comment: ""))
		}
		
	}
}

