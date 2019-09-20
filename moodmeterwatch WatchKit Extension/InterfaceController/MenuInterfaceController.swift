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
		sharing.itemLabel.setText("Live sharing")
		
		//let export = self.table.rowController(at: 1) as! MyRowController
		//export.itemImage.setImage(UIImage(systemName: "square.and.arrow.up"))
		//export.itemLabel.setText("Export File")
		
		let reminder = self.table.rowController(at: 1) as! MyRowController
		reminder.itemImage.setImage(UIImage(systemName: "clock"))
		reminder.itemLabel.setText("Reminder")
		
		let item2 = self.table.rowController(at: 2) as! MyRowController
		item2.itemImage.setImage(UIImage(systemName: "delete.right"))
		item2.itemLabel.setText("Delete data")
		item2.itemLabel.setTextColor(#colorLiteral(red: 1, green: 0.4156862745, blue: 0.337254902, alpha: 1))
	}
	override func table(_ table: WKInterfaceTable,
						didSelectRowAt rowIndex: Int){
		switch rowIndex {
		case 0:
			if Model.shared.userHash == nil {
				let accept = WKAlertAction(title: "Accept", style: .default) {
					self.pushController(withName: "Share", context: nil)
				}
				let read = WKAlertAction(title: "Read", style: .default) {
					self.presentAlert(withTitle: "Terms and conditions", message: "This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.This is a looong text.", preferredStyle: .actionSheet, actions: [accept])
				}
				
				presentAlert(withTitle: "Terms and conditions", message: "By using the share feature you accept the terms and conditions.", preferredStyle: .actionSheet, actions: [read, accept])
			} else {
				pushController(withName: "Share", context: nil)
			}
		case 1:
			self.pushController(withName: "Reminder", context: nil)
		case 2:
			let accept = WKAlertAction(title: "Yes, delete", style: .destructive) {
				_ = Model.shared.eraseData()
			}
			presentAlert(withTitle: "Delete data?", message: "This will permanently delete your local data on your watch and phone.", preferredStyle: .actionSheet, actions: [ accept])
			
		default: print("export not supported")
		}
		
	}
}

