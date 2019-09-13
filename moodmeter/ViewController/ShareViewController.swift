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

class ShareViewController: UIViewController {
	
	// MARK: Outlets
	@IBOutlet weak var activateSharing: UIView!
	@IBOutlet weak var sharedView: UIView!
	@IBOutlet weak var shareLinkField: UITextField!
	@IBOutlet weak var termsText: TTTAttributedLabel!
	
	// MARK: IBActions
	@IBAction func shareLiveButton(_ sender: Any) {
		showSharingActivated()
	}
	
	@IBAction func deleteShared(_ sender: Any) {
		confirm(title: NSLocalizedString("Disable?", comment: ""),
				message: NSLocalizedString("Disabling the sharing deletes all remotely saved data.", comment: "")) { action in
					Model.shared.disableSharing()
					MoodAPIjsonHttpClient.shared.delete()
					self.showSharingDeactivated()
		}
	}
	
	@IBAction func exportLink(_ sender: Any) {
		let textToShare = NSLocalizedString("My live mood data", comment: "")
		
		if let myWebsite = URL(string: Model.shared.sharingURL) {
			let objectsToShare: [Any] = [textToShare, myWebsite]
			let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			
			activityVC.popoverPresentationController?.sourceView = self.view
			self.present(activityVC, animated: true, completion: nil)
		}
	}
	
	@IBAction func exportFileButton(_ sender: Any) {
		//let tmpDirURL = FileManager.default.temporaryDirectory
		let filename = Date().toJS()+".csv"
		let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
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
				documentController.uti = "public.comma-separated-values-text"
				documentController.name = filename
				//documentController.presentPreview(animated: true)
				documentController.presentOptionsMenu(from: (sender as AnyObject).frame, in:self.view, animated:true)
			}
		}.resume()
	}
	
	@IBAction func reloadButton(_ sender: Any) {
		Model.shared.generateSharingURL()
		shareLinkField.text = Model.shared.sharingURL
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
		shareLinkField.text = Model.shared.sharingURL
	}
}
