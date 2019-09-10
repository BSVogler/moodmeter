//
//  ShareViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 29.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
final class GradientView: UIView {
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
	
	
	@IBOutlet weak var activateSharing: UIView!
	@IBOutlet weak var sharedView: UIView!
	@IBOutlet weak var shareLinkField: UITextField!
	
	@IBAction func shareLiveButton(_ sender: Any) {
		showSharingActivated()
	}
	
	@IBAction func deleteShared(_ sender: Any) {
		Model.shared.disableSharing()
		MoodAPIjsonHttpClient.shared.delete()
		showSharingDeactivated()
	}
	
	@IBAction func exportButton(_ sender: UIView) {
		let textToShare = "Swift is awesome!  Check out this website about it!"
		
		if let myWebsite = URL(string: "http://www.codingexplorer.com/") {
			let objectsToShare: [Any] = [textToShare, myWebsite]
			let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			
			activityVC.popoverPresentationController?.sourceView = sender
			self.present(activityVC, animated: true, completion: nil)
		}
	}
	
	@IBAction func reloadButton(_ sender: Any) {
		Model.shared.generateSharingURL()
		shareLinkField.text = Model.shared.sharingURL
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if Model.shared.deviceHash == nil {
			showSharingDeactivated()
		} else {
			showSharingActivated()
		}
	}
	
	func showSharingDeactivated() {
		sharedView.isHidden = true
		activateSharing.isHidden = false
	}
	
	func showSharingActivated() {
		sharedView.isHidden = false
		activateSharing.isHidden = true
		shareLinkField.text = Model.shared.sharingURL
	}
}
