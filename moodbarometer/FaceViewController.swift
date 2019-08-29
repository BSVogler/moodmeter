//
//  DataViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {

	@IBOutlet weak var dataLabel: UILabel!
	@IBOutlet weak var innerView: UIView!
	
	var topLabel: String = ""
	var modelController: PageViewController?

	@IBOutlet weak var moodLabel: UILabel!
	@IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
		modelController?.increaseMood()
		moodLabel.text = modelController?.getSmiley()
		self.view.backgroundColor = modelController?.getColor()
		moodLabel.rotation = 90
		innerView.backgroundColor = self.view.backgroundColor
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		modelController?.decreaseMood()
		moodLabel.text = modelController?.getSmiley()
		self.view.backgroundColor = modelController?.getColor()
		innerView.backgroundColor = self.view.backgroundColor
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.dataLabel!.text = topLabel
	}

}

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

