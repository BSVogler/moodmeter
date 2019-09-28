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
		if let _ = sharingHash.userHash,
            let shareURL = sharingHash.urlWithoutProtocol {
            hashLabel.setText(shareURL)
        } else {
            hashLabel.setText("...wait...")
            sharingHash.generateAndRegisterHash() {
                self.hashLabel.setText(self.sharingHash.urlWithoutProtocol)
            }
        }
    }
    
    override func didAppear() {
        self.hashLabel.setText(sharingHash.urlWithoutProtocol)
    }
    
    // MARK: IBActions
	@IBAction func generateNewLink() {
		hashLabel.setText("...wait...")
        
		// generate new sharing url
        sharingHash.generateAndRegisterHash() {
            self.hashLabel.setText(self.sharingHash.url?.absoluteString)
		}
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
}
