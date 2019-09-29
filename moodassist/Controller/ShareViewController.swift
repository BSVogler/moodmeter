//
//  ShareViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 29.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import UIKit

// MARK: - GradientView
@IBDesignable
final class GradientView: UIView, UIDocumentInteractionControllerDelegate {
	@IBInspectable var startColor: UIColor = UIColor.clear
	@IBInspectable var endColor: UIColor = UIColor.clear
	
	override func draw(_ rect: CGRect) {
		let gradient: CAGradientLayer = CAGradientLayer()
		gradient.frame = CGRect(x: CGFloat(0),
								y: CGFloat(0),
								width: superview!.frame.size.width,
								height: superview!.frame.size.height)
		gradient.colors = [startColor.cgColor, endColor.cgColor]
		gradient.zPosition = -1
		layer.addSublayer(gradient)
	}
}

//MARK: - ShareViewController
class ShareViewController: UIViewController {
	
	// MARK: Outlets
	@IBOutlet private weak var activateSharing: UIView!
	@IBOutlet private weak var sharedView: UIView!
	@IBOutlet private weak var shareLinkField: UITextField!
	@IBOutlet private weak var termsText: UITextView!
	@IBOutlet private weak var exportButton: UIButton!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var shareLiveDataButton: UIButton!
	
    // MARK: Overridden/ Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.isHidden = true
        if Model.shared.sharing.userHash == nil {
            showSharingDeactivated()
        } else {
            showSharingActivated()
        }
        shareLinkField.delegate = self
        //disable keyboard
        shareLinkField.inputView = UIView.init(frame: .zero)
    }
    
	// MARK: IBActions
	@IBAction func shareLiveButton(_ sender: Any) {
		activityIndicator.isHidden = false
		shareLiveDataButton.isHidden = true
		activityIndicator.startAnimating()
		Model.shared.sharing.generateAndRegisterHash() { succ, err in
			if succ {
				self.shareLinkField.text = Model.shared.sharing.URL?.absoluteString
				self.showSharingActivated()
			} else {
				self.showSharingDeactivated()
			}
			self.activityIndicator.stopAnimating()
		}
	}
	
	@IBAction func deleteShared(_ sender: Any) {
		confirm(title: NSLocalizedString("Disable?", comment: ""),
				message: NSLocalizedString("Disabling the sharing deletes all remotely saved data.", comment: "")
		) { action in
			self.activityIndicator.startAnimating()
			MoodApiJsonHttpClient.shared.delete { res in
				print (res.debugDescription)
				Model.shared.sharing.disableSharing()
				self.activityIndicator.stopAnimating()
				self.showSharingDeactivated()
			}
		}
	}
	
	@IBAction func reloadHash(_ sender: Any) {
		if Model.shared.sharing.userHash != nil {
			shareLinkField.text = "..."
			//generate new sharing url
			Model.shared.sharing.generateAndRegisterHash() { succ, err in
				self.shareLinkField.text = Model.shared.sharing.URL?.absoluteString
			}
		} else {
			//has no hash (only the case if there is a bug somehwere else), so make a new one
			Model.shared.sharing.generateAndRegisterHash(){ succ, err in
				if succ {
					self.shareLinkField.text = Model.shared.sharing.URL?.absoluteString
				}
			}
		}
	}
	
	@IBAction func exportLink(_ sender: Any) {
		let textToShare = NSLocalizedString("My live mood data", comment: "")
		
		if let link = Model.shared.sharing.URL {
			let objectsToShare: [Any] = [textToShare, link]
			let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			
			activityVC.popoverPresentationController?.sourceView = self.view
			self.present(activityVC, animated: true, completion: nil)
		}
	}
	
	@IBAction func exportFileButton(_ sender: Any) {
		let labelBefore = exportButton.titleLabel?.text
		exportButton.titleLabel?.text = NSLocalizedString("Exporting…", comment: "")//never visible, but this triggers some fade-out animation
		let tmpDirURL = FileManager.default.temporaryDirectory
		let filename = Date().toJS()+".csv"
		let url = tmpDirURL.appendingPathComponent(filename)
		URLSession.shared.dataTask(with: url) { data, response, error in
			do {
				try Model.shared.exportCSV().write(to: url, atomically: true, encoding: .utf8)
			} catch {
				self.alert(title: "Failed", message: "Export not working: +\(error)")
			}
			guard FileManager().fileExists(atPath: url.relativePath) else{
				self.alert(title: "Failed", message: "File not saved at +\(url)")
				return
			}
			DispatchQueue.main.async {
				let documentController = UIDocumentInteractionController(url: url)
				documentController.delegate = self
				documentController.uti = "public.comma-separated-values-text"
				documentController.name = filename
				documentController.presentPreview(animated: true) //this works
				//documentController.presentOptionsMenu(from: (sender as AnyObject).frame, in:self.view, animated:true) //this does not work
			}
		}.resume()
		exportButton.titleLabel?.text = labelBefore
	}
	
	// MARK: Instance Methods
	func showSharingDeactivated() {
		sharedView.isHidden = true
		activateSharing.isHidden = false
		shareLiveDataButton.isHidden = false
		let attributedString = NSMutableAttributedString(string: NSLocalizedString(termsText.text, comment: "") )
		let foundRange = attributedString.mutableString.range(of: NSLocalizedString("terms and conditions", comment: ""))
		guard foundRange.location != NSNotFound else {
			print("String or Localization error")
			return
		}
		let url = URL(string:NSLocalizedString("https://moodassist.cloud/privacy", comment: ""))!
		attributedString.addAttribute(.link, value: url, range: foundRange)
		termsText.attributedText = attributedString
	}
	
	func showSharingActivated() {
		sharedView.isHidden = false
		activateSharing.isHidden = true
		shareLinkField.text = Model.shared.sharing.URL?.absoluteString
	}

}

// MARK: - Extensions
// MARK: UITextFieldDelegate
extension ShareViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // copy to pasteboard
        UIPasteboard.general.string = shareLinkField.text
        return textField != shareLinkField
    }
}

// MARK: UIDocumentInteractionControllerDelegate
extension ShareViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
