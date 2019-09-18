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

