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
		if Sharing.hashlength==value?.length {
			importButton.setEnabled(true)
		} else {
			importButton.setEnabled(false)
		}
		
	}
	@IBAction func importButtonPressed() {
		Model.shared.sharing.importHash(enteredHash) { succ, err in
			if succ {
				self.pop()
			} else {
				self.presentAlert(withTitle: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("failed. Check your code.\n", comment: "")+(err?.localizedDescription ?? ""), preferredStyle: .alert, actions: [ WKAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) {}])
			}
		}
	}
	
	override func awake(withContext context: Any?) {
		importButton.setEnabled(false)
	}
	
}
