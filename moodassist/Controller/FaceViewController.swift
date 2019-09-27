//
//  FaceViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import UIKit

// MARK: - DesignableLabel
@IBDesignable
class DesignableLabel: UILabel {
}

// MARK: - FaceViewController
class FaceViewController: UIViewController {

	// MARK: Stored Instance Properties
	var topLabel: String = ""
	var modelController: PageViewController?
	private var face = Measurement()
	
	// MARK: IBOutlets
	@IBOutlet private weak var dataLabel: UILabel!
	@IBOutlet private weak var innerView: UIView!
	@IBOutlet private weak var moodLabel: UILabel!
    
    // MARK: Overridden/ Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = topLabel
        face.mood = Model.shared.dataset[face.date.toJS()] ?? 0
        refreshDisplay()
    }
    
	// MARK: IBActions
	@IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 4
			face.moodChanged()
		} else if face.mood < Measurement.moodToText.count-1 {
			face.mood += 1
			face.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 2
			face.moodChanged()
		} else if face.mood > 1 {
			face.mood -= 1
			face.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func tapped(_ sender: Any) {
		if face.mood == 0 {
			face.mood = 3
			face.moodChanged()
			refreshDisplay()
		}
	}
	
	// MARK: Instance Methods
	func refreshDisplay(){
		moodLabel.text = face.getSmiley()
		self.view.backgroundColor = face.getColor()
		innerView.backgroundColor = self.view.backgroundColor
		if !face.isYesterday,
			face.mood != 0 {
			UIApplication.shared.applicationIconBadgeNumber = 0;
		}
	}
	
	func setToYesterday(){
		face.setToYesterday()
	}
}

// MARK: - Extensions
// MARK: UIView: IBInspectable
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
