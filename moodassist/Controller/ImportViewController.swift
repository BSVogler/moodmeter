//
//  ImportViewController.swift
//  Moodassist
//
//  Created by Benedikt Stefan Vogler on 27.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit

<<<<<<< HEAD:moodassist/Controller/ImportViewController.swift
// MARK: - ImportViewController
=======
protocol URLupdaterDelegate {
	func updatedURL()
}

>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/ImportViewController.swift
class ImportViewController: UIViewController {
    
    // MARK: Stored Instance Properties
	var enteredHash: String = ""
	var delegate: URLupdaterDelegate?
	
    // MARK: IBOutlets
	@IBOutlet private weak var codeField: UITextField!
	@IBOutlet private weak var importButton: UIButton!
	
    // MARK: IBActions
	@IBAction func codeChanged(_ sender: Any) {
		codeField.text = codeField.text?.uppercased()
		enteredHash = codeField.text ?? ""
<<<<<<< HEAD:moodassist/Controller/ImportViewController.swift
        if SharingConstants.hashLength == enteredHash.count {
=======
		if enteredHash.count > 1 {
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/ImportViewController.swift
			importButton.isEnabled = true
		} else {
			importButton.isEnabled = false
		}
		
	}
    
	@IBAction func cancel(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func importButtonPressed() {
<<<<<<< HEAD:moodassist/Controller/ImportViewController.swift
        DataHandler.userProfile.sharingHash.importHash(enteredHash) {
			self.dismiss(animated: true, completion: nil)
=======
		Model.shared.sharing.importHash(enteredHash) { succ, err in
			if succ {
				self.delegate?.updatedURL()
				self.dismiss(animated: true, completion: nil)
			} else {
				self.alert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Check your code", comment: "")+"\n"+(err?.localizedDescription ?? ""))
			}
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/ImportViewController.swift
		}
	}
}
