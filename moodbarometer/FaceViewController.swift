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
	
	private var moodToText: [String] = ["?", ":-(", ":-/", ":-|", ":-)", ":-D"]
	private var moodToColor: [UIColor] = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)]
	
	//do not like this construct, but computed properties are only working this way
	private var dateWithoutHours: Date = Date()
	
	private var date: Date {
		set {
			let calendar = Calendar.current
			dateWithoutHours = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: newValue)!
		}
		get {return dateWithoutHours}
	}
	
	private var mood: Mood = 3
	var yesterday: Date? {
		let calendar = Calendar.current
		return calendar.date(byAdding: .day, value: -1, to: date)
	}

	@IBOutlet weak var moodLabel: UILabel!
	@IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
		increaseMood()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		decreaseMood()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		date = Date()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		date = Date()
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		refreshDisplay()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.dataLabel!.text = topLabel
	}
	
	func getSmiley() -> String {
		return moodToText[mood]
	}
	
	func getColor() -> UIColor {
		return moodToColor[mood]
	}
	
	func increaseMood(){
		if mood < moodToText.count-1 {
			mood += 1
			Model.shared.dataset[date] = mood
			Model.shared.saveToJSON()
			modelController?.httpClient?.postMeasurement(measurements: [Measurement(day: Date(), mood: mood)])
		}
		refreshDisplay()
	}
	
	func decreaseMood(){
		if mood > 1 {
			mood -= 1
			Model.shared.dataset[date] = mood
			Model.shared.saveToJSON()
			modelController?.httpClient?.postMeasurement(measurements: [Measurement(day: Date(), mood: mood)])
		}
		refreshDisplay()
	}
	
	func setToYesterday(){
		date = yesterday ?? date
	}

	func refreshDisplay(){
		mood = Model.shared.dataset[date] ?? 3
		moodLabel.text = getSmiley()
		self.view.backgroundColor = getColor()
		innerView.backgroundColor = self.view.backgroundColor
	
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

