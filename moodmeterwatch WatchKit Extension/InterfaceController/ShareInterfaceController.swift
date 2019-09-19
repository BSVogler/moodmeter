//
//  ShareInterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 18.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import WatchKit

class ShareInterfaceController: WKInterfaceController {
	
	@IBOutlet weak var hashLabel: WKInterfaceLabel!
	
	@IBAction func generateNewLink() {
		hashLabel.setText("...wait...")
		//generate new sharing url
		Model.shared.generateAndRegisterHash(){
			self.hashLabel.setText(Model.shared.sharingURL?.absoluteString)
		}
	}
	@IBAction func delete() {
		let accept = WKAlertAction(title: NSLocalizedString("Yes, delete", comment: ""), style: .destructive) {
			//wait for confirm from server
			MoodAPIjsonHttpClient.shared.delete { res in
				print (res.debugDescription)
				Model.shared.disableSharing()
				self.pop()
			}
		}
		presentAlert(withTitle: NSLocalizedString("Disable?", comment: ""), message: NSLocalizedString("Disabling the sharing deletes all remotely saved data.", comment: ""), preferredStyle: .actionSheet, actions: [ accept])
	}
	
	override func awake(withContext context: Any?) {
		if Model.shared.sharingURLShort != nil {
			hashLabel.setText(Model.shared.sharingURLShort)
		} else {
			hashLabel.setText("...wait...")
			Model.shared.generateAndRegisterHash(){
				self.hashLabel.setText(Model.shared.sharingURLShort)
			}
		}
	}
	
	override func didAppear() {
		self.hashLabel.setText(Model.shared.sharingURLShort)
	}
}

