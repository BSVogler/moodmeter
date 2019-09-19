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
	
	@IBOutlet weak var importButton: WKInterfaceButton!
	
	@IBAction func codeChanged(_ value: NSString?) {
		if Model.hashlength==value?.length {
			importButton.setEnabled(true)
		} else {
			importButton.setEnabled(false)
		}
		
	}
	@IBAction func importButtonPressed() {
	}
	
}
