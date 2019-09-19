//
//  ImportInterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 19.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import WatchKit

class ImportInterfaceController: WKInterfaceController {
	var enteredHash: String = ""
	
	@IBOutlet weak var importButton: WKInterfaceButton!
	
	@IBAction func codeChanged(_ value: NSString?) {
		enteredHash = (value ?? "")  as String 
		if Model.hashlength==value?.length {
			importButton.setEnabled(true)
		} else {
			importButton.setEnabled(false)
		}
		
	}
	@IBAction func importButtonPressed() {
		Model.shared.importHash(enteredHash) {
			self.pop()
		}
	}
	
	override func awake(withContext context: Any?) {
		importButton.setEnabled(false)
	}
	
}
