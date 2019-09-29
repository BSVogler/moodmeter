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
	private var face = Measurement()
	private var faceRenderer = FaceRenderer()
	private var audioPlayer:AVAudioPlayer!
	
	// MARK: IBOutlets
	@IBOutlet private weak var dataLabel: UILabel!
	@IBOutlet private weak var innerView: UIView!
	@IBOutlet private weak var faceImageView: UIImageView!
	
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
			playSound()
			face.moodChanged()
		} else if face.mood < Measurement.moodToText.count-1 {
			face.mood += 1
			playSound()
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
			playSound()
			face.moodChanged()
		} else if face.mood > 1 {
			face.mood -= 1
			playSound()
			face.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func tapped(_ sender: Any) {
		if face.mood == 0 {
			face.mood = 3
			playSound()
			face.moodChanged()
			refreshDisplay()
		}
	}
	
	// MARK: Instance Methods
	func refreshDisplay(){
		self.view.backgroundColor = face.getColor()
		innerView.backgroundColor = self.view.backgroundColor
		if !face.isYesterday,
			face.mood != 0 {
			UIApplication.shared.applicationIconBadgeNumber = 0;
		}
		faceRenderer.scale = UIScreen.main.scale
		faceRenderer.mood = face.mood
		faceImageView.image = faceRenderer.getImage(rect: faceImageView.frame)
	}
	
	func setToYesterday(){
		face.setToYesterday()
	}
	
	func playSound(){
		if let audioFilePath = Bundle.main.path(forResource: "sounds/"+String(face.mood), ofType: "m4a") {
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
