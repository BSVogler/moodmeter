//
//  HistoryViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 24.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit

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
	}
	
	@IBAction func navigateForward(_ sender: Any) {
		diagramController.navigateForward()
		refreshRendering()
	}
	
	@IBAction func navigateBackwards(_ sender: Any) {
		diagramController.navigateBack()
		refreshRendering()
	}
	
	// MARK: stored properties
	let diagramController = DiagramController()
	private let diagram : Diagram
	
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
}
