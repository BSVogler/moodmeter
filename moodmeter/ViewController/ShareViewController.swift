//
//  ShareViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 29.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import UIKit
import TTTAttributedLabel

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

class ShareViewController: UIViewController, UIDocumentInteractionControllerDelegate {
	
	// MARK: Outlets
	@IBOutlet weak var activateSharing: UIView!
	@IBOutlet weak var sharedView: UIView!
	@IBOutlet weak var shareLinkField: UITextField!
	@IBOutlet weak var termsText: TTTAttributedLabel!
	@IBOutlet weak var exportButton: UIButton!
	
	// MARK: IBActions
	@IBAction func shareLiveButton(_ sender: Any) {
		Model.shared.generateAndRegisterSharingURL(){ res in
			self.shareLinkField.text = Model.shared.sharingURL?.absoluteString
		}
		showSharingActivated()
	}
	
	@IBAction func deleteShared(_ sender: Any) {
		confirm(title: NSLocalizedString("Disable?", comment: ""),
				message: NSLocalizedString("Disabling the sharing deletes all remotely saved data.", comment: "")) { action in
					MoodAPIjsonHttpClient.shared.delete { res in
						print (res)
					}
					Model.shared.disableSharing()
					self.showSharingDeactivated()
		}
	}
	
	@IBAction func reloadHash(_ sender: Any) {
		if let oldHash = Model.shared.deviceHash {
			shareLinkField.text = "..."
			//generate new sharing url
			Model.shared.generateSharingURL()
			MoodAPIjsonHttpClient.shared.moveHash(old: oldHash) { res in
				self.shareLinkField.text = Model.shared.sharingURL?.absoluteString
			}
		} else {
			//has no hash (only the case if there is a bug somehwere else), so make a new one
			Model.shared.generateAndRegisterSharingURL(){ res in
				self.shareLinkField.text = Model.shared.sharingURL?.absoluteString
			}
		}
	}
	
	@IBAction func exportLink(_ sender: Any) {
		let textToShare = NSLocalizedString("My live mood data", comment: "")
		
		if let link = Model.shared.sharingURL {
			let objectsToShare: [Any] = [textToShare, link]
			let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			
			activityVC.popoverPresentationController?.sourceView = self.view
			self.present(activityVC, animated: true, completion: nil)
		}
	}
	
	func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
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
	
	// MARK: Override
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if Model.shared.deviceHash == nil {
			showSharingDeactivated()
		} else {
			showSharingActivated()
		}
	}
	
	// MARK: Functions
	func showSharingDeactivated() {
		sharedView.isHidden = true
		activateSharing.isHidden = false
		let attributedString = NSMutableAttributedString(string: termsText.text as! String)
		let foundRange = attributedString.mutableString.range(of: NSLocalizedString("terms and conditions", comment: ""))
		guard foundRange.location != NSNotFound else {
			print("String or Localization error")
			return
		}
		let url = NSURL(fileURLWithPath: "https://benediktsvogler.com/terms")
		attributedString.addAttribute(.link, value: url, range: foundRange)
		termsText.setText(attributedString)
	}
	
	func showSharingActivated() {
		sharedView.isHidden = false
		activateSharing.isHidden = true
		shareLinkField.text = Model.shared.sharingURL?.absoluteString
	}
}
