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
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		// Configure interface objects here.
		table.setNumberOfRows(3, withRowType: "menuItem")
		
		let item0 = self.table.rowController(at: 0) as! MyRowController
		
		item0.itemImage.setImage(UIImage(systemName: "cloud"))
		item0.itemLabel.setText("Live sharing")
		
		let item1 = self.table.rowController(at: 1) as! MyRowController
		
		item1.itemImage.setImage(UIImage(systemName: "square.and.arrow.up"))
		item1.itemLabel.setText("Export File")
		
		let item2 = self.table.rowController(at: 2) as! MyRowController
		
		item2.itemImage.setImage(UIImage(systemName: "delete.right"))
		item2.itemLabel.setText("Delete data")
		item2.itemLabel.setTextColor(#colorLiteral(red: 1, green: 0.4156862745, blue: 0.337254902, alpha: 1))
	}
	override func table(_ table: WKInterfaceTable,
						didSelectRowAt rowIndex: Int){
		switch rowIndex {
			case 0: pushController(withName: "Share", context: nil)
			case 2: pushController(withName: "Delete", context: nil)
			default: print("export not supported")
		}
		
	}
}

