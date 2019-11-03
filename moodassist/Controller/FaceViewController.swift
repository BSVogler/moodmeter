//
//  FaceViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import UIKit
import AVFoundation

// MARK: - FaceViewController
class FaceViewController: UIViewController {

	// MARK: Stored Instance Properties
	var topLabel: String = ""
	var modelController: PageViewController?
	private var measure: Measurement
	private var faceRenderer = FaceRenderer()
	private var audioPlayer:AVAudioPlayer!
	private var moodbefore = 0
	
	// MARK: IBOutlets
	@IBOutlet private weak var dataLabel: UILabel!
	@IBOutlet private weak var innerView: UIView!
	@IBOutlet private weak var faceImageView: UIImageView!
	@IBOutlet weak var tutorialView: UIView!
	
	// MARK: Initializers
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		if let existingMeasurement = Model.shared.getMeasurement(at: Date.today()) {
			measure = existingMeasurement
		} else {
			measure = Measurement(day: Date.today(), mood: 0)
		}
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		if let existingMeasurement = Model.shared.getMeasurement(at: Date.today()) {
			measure = existingMeasurement
		} else {
			measure = Measurement(day: Date.today(), mood: 0)
		}
		super.init(coder: coder)
	}
	
    // MARK: Overridden/ Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = topLabel
		Model.shared.sharing.refresh() {
			self.refreshDisplay()
		}
        refreshDisplay()
    }
    
	// MARK: IBActions
	@IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
		//mood 0 is only internal special case
		if measure.mood == 0 {
			moodbefore = measure.mood
			measure.mood = 4
			playSound()
			Model.shared.addMeasurment(measure)
			measure.moodChanged()
		} else if measure.mood < Measurement.moodToText.count-1 {
			moodbefore = measure.mood
			measure.mood += 1
			playSound()
			measure.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		//mood 0 is only internal special case
		if measure.mood == 0 {
			moodbefore = measure.mood
			measure.mood = 2
			playSound()
			Model.shared.addMeasurment(measure)
			measure.moodChanged()
		} else if measure.mood > 1 {
			moodbefore = measure.mood
			measure.mood -= 1
			playSound()
			measure.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func tapped(_ sender: Any) {
		if measure.mood == 0 {
			measure.mood = 3
			playSound()
			Model.shared.addMeasurment(measure)
			measure.moodChanged()
			refreshDisplay()
		}
	}
	
	// MARK: Instance Methods
	func refreshDisplay(){
		self.view.backgroundColor = measure.getColor()
		innerView.backgroundColor = self.view.backgroundColor
		if !measure.isYesterday,
			measure.mood != 0 {
			UIApplication.shared.applicationIconBadgeNumber = 0;
		}
		faceRenderer.scale = UIScreen.main.scale
		//first set the static image
		if measure.mood > 0 && moodbefore == 0 {
			moodbefore = measure.mood
		}
		let animation = faceRenderer.getAnimation(rect: faceImageView.frame,from: moodbefore, to: measure.mood)
		faceImageView.image = animation.last
		//animate
		faceImageView.animationImages = animation
		faceImageView.animationDuration = 0.20;
		faceImageView.animationRepeatCount = 1;
		faceImageView.startAnimating()
		tutorialView.isHidden = measure.mood != 0
	}
	
	func setToYesterday(){
		let date = Date.yesterday()
		if  let existingMeasurement = Model.shared.getMeasurement(at: date) {
			measure = existingMeasurement
		} else {
			measure = Measurement(day: date, mood: 0)
		}
	}
	
	func playSound(){
		if let audioFilePath = Bundle.main.path(forResource: "sounds/"+String(measure.mood), ofType: "m4a") {
			do {
				audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioFilePath), fileTypeHint: AVFileType.m4a.rawValue)
				guard let audioPlayer = audioPlayer else { return }
				audioPlayer.play()
			} catch let error {
				print(error.localizedDescription)
			}
		}
	}
}
