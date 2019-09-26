//
//  HistoryViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 24.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit
import SwiftChartView

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
	}
	
	required init?(coder: NSCoder) {
		self.diagram = Diagram(controller: diagramController)
		super.init(coder: coder)
	}
	
	// MARK: functions
	func refreshRendering(){
		//let sortedDates = Model.shared.dataset.keys.sorted(by: {$0.compare($1) == .orderedDescending})
		
		//dataset to string
		diagramImage.image = diagram.getImage(frame: diagramImage.frame, scale: UIScreen.main.scale)
		
		rangeDisplay.text = diagramController.getRangeText()
	}
	
	override func viewDidLoad() {
	}
	
	override func viewWillAppear(_ animated: Bool) {
		refreshRendering()
	}
}
