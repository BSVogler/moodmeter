//
//  HistoryViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 24.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit
import StoreKit

class HistoryViewController: UIViewController {
	
	@IBOutlet weak var diagramImage: UIImageView!
	@IBOutlet weak var rangeSelector: UISegmentedControl!
	@IBOutlet weak var rangeDisplay: UILabel!
	@IBOutlet weak var averageLabel: UILabel!
	
	// MARK: IBActions
	@IBAction func displayRangeChanged(_ sender: Any) {
		switch rangeSelector.selectedSegmentIndex {
		case 0:
			diagramController.analysisrange = .week
		case 1:
			diagramController.analysisrange = .month
		default:
			diagramController.analysisrange = .year
		}
		refreshRendering()
		actionToShowReview()
	}
	
	@IBAction func navigateForward(_ sender: Any) {
		diagramController.navigateForward()
		refreshRendering()
		actionToShowReview()
	}
	
	@IBAction func navigateBackwards(_ sender: Any) {
		diagramController.navigateBack()
		refreshRendering()
		actionToShowReview()
	}
	
	// MARK: stored properties
	let diagramController = DiagramController()
	private let diagram : Diagram
	private var canCreateNewReview = true
	
	// MARK: initializers
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		self.diagram = Diagram(controller: diagramController)
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.refreshRendering), name: Measurement.changedNotification, object: nil)
	}
	
	required init?(coder: NSCoder) {
		self.diagram = Diagram(controller: diagramController)
		super.init(coder: coder)
	}
	
	// MARK: functions
	@objc func refreshRendering(){
		diagram.frame = diagramImage.frame
		rangeDisplay.text = diagramController.getRangeText()
		diagramImage.image = diagram.getImage(scale: UIScreen.main.scale)
	}
	
	override func viewDidLoad() {
	}
	
	override func viewWillAppear(_ animated: Bool) {
		diagram.frame = diagramImage.frame
		refreshRendering()

	}
	override func viewDidAppear(_ animated: Bool) {
		//causes a correct size redraw #49
		diagram.frame = diagramImage.frame
		refreshRendering()
	}
	
	///call this when an action could potentially request a review
	private func actionToShowReview(){
		var count = UserDefaults.standard.integer(forKey: "processCompletedCount")
		count += 1
		UserDefaults.standard.set(count, forKey: "processCompletedCount")

		// Has the process been completed several times and the user is semi-experienced?
		if count >= 3 && (Model.shared.measurements.count > 2) {
			// and the user has not already been prompted for this version?
			// Get the current bundle version for the app
			let infoDictionaryKey = kCFBundleVersionKey as String
			guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
				else { fatalError("Expected to find a bundle version in the info dictionary") }
			let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReview")
			if currentVersion != lastVersionPromptedForReview {
				if canCreateNewReview { // only show a single one until completion
					canCreateNewReview = false
					let secondsFromNow = DispatchTime.now() + 1.5
					DispatchQueue.main.asyncAfter(deadline: secondsFromNow) {
						SKStoreReviewController.requestReview()
						UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReview")
						//don't spam imediately after each udpate
						UserDefaults.standard.set(0, forKey: "processCompletedCount")
						self.canCreateNewReview = true
					}
				}
			}
		}
	}
}
