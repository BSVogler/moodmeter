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
		if let oldHash = Model.shared.deviceHash {
			hashLabel.setText("...wait...")
			//generate new sharing url
			Model.shared.generateSharingURL()
			MoodAPIjsonHttpClient.shared.moveHash(old: oldHash) { res in
				self.hashLabel.setText(Model.shared.sharingURL?.absoluteString)
			}
		} else {
			//has no hash (only the case if there is a bug somehwere else), so make a new one
			Model.shared.generateAndRegisterSharingURL(){ res in
				self.hashLabel.setText(Model.shared.sharingURL?.absoluteString)
			}
		}
	}
	override func awake(withContext context: Any?) {
		if Model.shared.sharingURLShort != nil {
			hashLabel.setText(Model.shared.sharingURLShort)
		} else {
			hashLabel.setText("...wait...")
			Model.shared.generateAndRegisterSharingURL(){ res in
				self.hashLabel.setText(Model.shared.sharingURLShort)
			}
		}
	}
}

