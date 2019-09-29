//
//  ImportViewController.swift
//  Moodassist
//
//  Created by Benedikt Stefan Vogler on 27.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import UIKit

class ImportViewController: UIViewController {
	var enteredHash: String = ""
	
	@IBOutlet weak var codeField: UITextField!
	@IBOutlet weak var importButton: UIButton!
	
	@IBAction func codeChanged(_ sender: Any) {
		enteredHash = codeField.text ?? ""
		if Sharing.hashlength == enteredHash.count {
			importButton.isEnabled = true
		} else {
			importButton.isEnabled = false
		}
		
	}
	@IBAction func cancel(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func importButtonPressed() {
		Model.shared.sharing.importHash(enteredHash) { succ, err in
			if succ {
				self.dismiss(animated: true, completion: nil)
			} else {
				self.alert(title: NSLocalizedString("Failed", comment: ""), message: err?.localizedDescription ?? "error")
			}
		}
	}
}
