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

// MARK: - FaceType
enum FaceType {
    case yesterday, today
}

// MARK: - FaceViewController
class FaceViewController: UIViewController {

	// MARK: Stored Instance Properties
	var topLabel: String = ""
	var modelController: PageViewController?
	private var face = Measurement()
<<<<<<< HEAD:moodassist/Controller/FaceViewController.swift
    private var faceType: FaceType = .today
=======
	private var faceRenderer = FaceRenderer()
	private var audioPlayer:AVAudioPlayer!
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/FaceViewController.swift
	
	// MARK: IBOutlets
	@IBOutlet private weak var dataLabel: UILabel!
	@IBOutlet private weak var innerView: UIView!
	@IBOutlet private weak var faceImageView: UIImageView!
	@IBOutlet weak var tutorialView: UIView!
	
    // MARK: Overridden/ Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = topLabel
<<<<<<< HEAD:moodassist/Controller/FaceViewController.swift
        setCurrentFace()
=======
		Model.shared.sharing.refresh(){
			self.face.mood = Model.shared.dataset[self.face.date.toJS()] ?? 0
			self.refreshDisplay()
		}
        face.mood = Model.shared.dataset[face.date.toJS()] ?? 0
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/FaceViewController.swift
        refreshDisplay()
    }
    
	// MARK: IBActions
	@IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 4
<<<<<<< HEAD:moodassist/Controller/FaceViewController.swift
		} else if face.mood < MoodConstants.moodToText.count-1 {
			face.mood += 1
=======
			playSound()
			face.moodChanged()
		} else if face.mood < Measurement.moodToText.count-1 {
			face.mood += 1
			playSound()
			face.moodChanged()
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/FaceViewController.swift
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 2
<<<<<<< HEAD:moodassist/Controller/FaceViewController.swift
		} else if face.mood > 1 {
			face.mood -= 1
=======
			playSound()
			face.moodChanged()
		} else if face.mood > 1 {
			face.mood -= 1
			playSound()
			face.moodChanged()
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/FaceViewController.swift
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func tapped(_ sender: Any) {
		if face.mood == 0 {
			face.mood = 3
<<<<<<< HEAD:moodassist/Controller/FaceViewController.swift
=======
			playSound()
			face.moodChanged()
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/FaceViewController.swift
			refreshDisplay()
		}
	}
	
	// MARK: Instance Methods
	func refreshDisplay(){
		self.view.backgroundColor = face.getColor()
		innerView.backgroundColor = self.view.backgroundColor
		if !face.isFromYesterday(),
			face.mood != 0 {
			UIApplication.shared.applicationIconBadgeNumber = 0;
		}
		faceRenderer.scale = UIScreen.main.scale
		faceRenderer.mood = face.mood
		faceImageView.image = faceRenderer.getImage(rect: faceImageView.frame)
		tutorialView.isHidden = face.mood != 0
	}
	
	func setToYesterday(){
        faceType = .yesterday
        setCurrentFace()
	}
<<<<<<< HEAD:moodassist/Controller/FaceViewController.swift
    
    // MARK: Private Instance Methods
    private func setCurrentFace() {
        switch faceType {
        case .today:
            // existing `Measurement` for today
            if let todaysMsmt = DataHandler.userProfile.dataset.first(where: { $0.day == Date.today }) {
                self.face = todaysMsmt
            } else {
                let newMsmtToday = Measurement()
                DataHandler.userProfile.dataset.append(newMsmtToday)
                self.face = newMsmtToday
            }
        case .yesterday:
            // existing `Measurement` for yesterday
            if let yesterdaysMsmt = DataHandler.userProfile.dataset.first(where: { $0.day == Date.yesterday }) {
                self.face = yesterdaysMsmt
            } else {
                if let yesterday = Date.yesterday {
                    let newMsmtYesterday = Measurement(day: yesterday, mood: 0)
                    DataHandler.userProfile.dataset.append(newMsmtYesterday)
                    self.face = newMsmtYesterday
                }
            }
        }
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
=======
	
	func playSound(){
		if let audioFilePath = Bundle.main.path(forResource: "sounds/"+String(face.mood), ofType: "m4a") {
			do {
				audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioFilePath), fileTypeHint: AVFileType.m4a.rawValue)
				guard let audioPlayer = audioPlayer else { return }
				audioPlayer.play()
			} catch let error {
				print(error.localizedDescription)
			}
>>>>>>> 3df75cb5e548a9661df72433774f8a082764c6ba:moodassist/Controller/FaceViewController.swift
		}
	}
		

}
