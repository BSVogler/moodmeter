//
//  DataViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {

	// MARK: Class
	static func getSmiley(mood: Mood) -> String {
		return moodToText[mood]
	}
	
	static func getColor(mood: Mood) -> UIColor {
		return moodToColor[mood]
	}
	
	static var moodToText: [String] = ["?", ":-(", ":-/", ":-|", ":-)", ":-D"]
	static var moodToColor: [UIColor] = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.6324028457, green: 0.5172401532, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5333333333, green: 1, blue: 0.2784313725, alpha: 1), #colorLiteral(red: 1, green: 0.8941176471, blue: 0.1490196078, alpha: 1)]
	
	// MARK: - Stored properties
	var topLabel: String = ""
	var modelController: PageViewController?
	private var isYesterday: Bool = false
	
	private var dateWithoutHours: Date = Date()
	
	// MARK: - Computed properties
	private var date: Date {
		set {
			let calendar = Calendar.current
			dateWithoutHours = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: newValue)!
		}
		get {return dateWithoutHours}
	}
	
	private var mood: Mood = 0
	var yesterday: Date? {
		let calendar = Calendar.current
		return calendar.date(byAdding: .day, value: -1, to: Date())
	}

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
		if mood == 0 {
			mood = 3
			moodChanged()
		}
	}
	// MARK: - Initializers
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		date = Date()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		date = Date()
	}
	
	// MARK: - Overrides
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.dataLabel!.text = topLabel
		refreshDisplay()
	}
	
	func increaseMood(){
		//mood 0 is only internal special case
		if mood == 0 {
			mood = 4
		} else if mood < FaceViewController.moodToText.count-1 {
			mood += 1
		} else {
			return
		}
		moodChanged()
	}
	
	func decreaseMood(){
		//mood 0 is only internal special case
		if mood == 0 {
			mood = 2
		} else if mood > 1 {
			mood -= 1
		} else {
			return
		}
		moodChanged()
	}
	
	func moodChanged(){
		Model.shared.dataset[date] = mood
		if !Model.shared.saveToFiles() {
			alert(title: "Error", message: "Could not save data")
		}
		MoodAPIjsonHttpClient.shared.postMeasurement(measurements: [Measurement(day: Date(), mood: mood)])
		refreshDisplay()
	}
	
	func setToYesterday(){
		isYesterday = true
		date = yesterday ?? date
	}

	func refreshDisplay(){
		if isYesterday {
			date = yesterday ?? date
		} else {
			date = Date()
		}
		mood = Model.shared.dataset[date] ?? 0
		moodLabel.text = FaceViewController.getSmiley(mood: mood)
		self.view.backgroundColor = FaceViewController.getColor(mood: mood)
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

