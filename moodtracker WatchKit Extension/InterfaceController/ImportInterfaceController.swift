//
//  ImportInterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 19.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import WatchKit

// MARK: ImportInterfaceController
class ImportInterfaceController: WKInterfaceController {
    
    // MARK: Stored Instance Properties
	var enteredHash: String = ""
	
    // MARK: IBOutlets
	@IBOutlet weak var importButton: WKInterfaceButton!
	
    // MARK: Overridden/ Lifecycle Methods
    override func awake(withContext context: Any?) {
        importButton.setEnabled(false)
    }
    
    // MARK: IBActions
    @IBAction func codeChanged(_ value: NSString?) {
        if let value = value,
            SharingConstants.hashLength == value.length {
            importButton.setEnabled(true)
        } else {
            importButton.setEnabled(false)
        }
	}
    
	@IBAction func importButtonPressed() {
        DataHandler.userProfile.sharingHash?.importHash(enteredHash) {
			self.pop()
		}
	}
	
}
