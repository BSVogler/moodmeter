//
//  ShareInterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 18.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import WatchKit

// MARK: - ShareInterfaceController
class ShareInterfaceController: WKInterfaceController {
	
    // MARK: Stored Instance Properties
	var sharingHash = DataHandler.userProfile.sharingHash
    
    // MARK: IBOutlets
	@IBOutlet weak var hashLabel: WKInterfaceLabel!
	
    // MARK: Overridden/ Lifecycle Methods
    override func awake(withContext context: Any?) {
        if let shareURL = DataHandler.userProfile.sharingHash.urlWithoutProtocol {
            hashLabel.setText(shareURL)
        } else {
            generateNewHash()
        }
    }
    
    override func didAppear() {
        self.hashLabel.setText(DataHandler.userProfile.sharingHash.urlWithoutProtocol)
    }
    
    // MARK: IBActions
	@IBAction func generateNewLink() {
		generateNewHash()
	}
	
	@IBAction func delete() {
		let accept = WKAlertAction(title: NSLocalizedString("Yes, delete", comment: ""), style: .destructive) {
			//wait for confirm from server
			MoodApiJsonHttpClient.shared.delete { res in
				print (res.debugDescription)
                self.sharingHash.disableSharing()
				self.pop()
			}
		}
		presentAlert(withTitle: NSLocalizedString("Disable?", comment: ""), message: NSLocalizedString("Disabling the sharing deletes all remotely saved data.", comment: ""), preferredStyle: .actionSheet, actions: [ accept])
	}
	
	func generateNewHash(){
		hashLabel.setText("...wait...")
		DataHandler.userProfile.sharingHash.registerHash() { succ, err in
			if succ {
                self.hashLabel.setText(DataHandler.userProfile.sharingHash.urlWithoutProtocol)
			} else {
				if let err = err {
					self.hashLabel.setText("failed: \(err.localizedDescription)")
				} else {
					self.hashLabel.setText("failed")
				}
			}
			
		}
	}
}
