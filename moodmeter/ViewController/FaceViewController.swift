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
	
	private var face = Face()
	
	// MARK: - Outlets
	@IBOutlet weak var dataLabel: UILabel!
	@IBOutlet weak var innerView: UIView!
	@IBOutlet weak var moodLabel: UILabel!
	// MARK: IBActions
	@IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
		increaseMood()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		decreaseMood()
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
		refreshDisplay()
	}
	
	// MARK: Functions
	func increaseMood(){
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 4
		} else if face.mood < Face.moodToText.count-1 {
			face.mood += 1
		} else {
			return
		}
		refreshDisplay()
	}
	
	func decreaseMood(){
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


	func refreshDisplay(){
		face.mood = Model.shared.dataset[face.date] ?? 0
		moodLabel.text = Face.getSmiley(mood: face.mood)
		self.view.backgroundColor = Face.getColor(mood: face.mood)
		innerView.backgroundColor = self.view.backgroundColor
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

