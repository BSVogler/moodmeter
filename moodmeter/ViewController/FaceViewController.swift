//
//  DataViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {

	// MARK: - Stored properties
	var topLabel: String = ""
	var modelController: PageViewController?
	
	private var face = Measurement()
	
	// MARK: - Outlets
	@IBOutlet weak var dataLabel: UILabel!
	@IBOutlet weak var innerView: UIView!
	@IBOutlet weak var moodLabel: UILabel!
	
	// MARK: IBActions
	@IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 4
		} else if face.mood < Measurement.moodToText.count-1 {
			face.mood += 1
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 2
		} else if face.mood > 1 {
			face.mood -= 1
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func tapped(_ sender: Any) {
		if face.mood == 0 {
			face.mood = 3
			refreshDisplay()
		}
	}
	
	// MARK: - Overrides
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.dataLabel!.text = topLabel
		face.mood = Model.shared.dataset[face.date] ?? 0
		refreshDisplay()
	}
	
	// MARK: Functions
	func refreshDisplay(){
		moodLabel.text = face.getSmiley()
		self.view.backgroundColor = face.getColor()
		innerView.backgroundColor = self.view.backgroundColor
	}
	
	func setToYesterday(){
		face.setToYesterday()
	}
}

// MARK: - Extension
@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
	@IBInspectable
	var rotation: Int {
		get {
			return 0
		} set {
			let radians = ((CGFloat.pi) * CGFloat(newValue) / CGFloat(180.0))
			self.transform = CGAffineTransform(rotationAngle: radians)
		}
	}
	
}

