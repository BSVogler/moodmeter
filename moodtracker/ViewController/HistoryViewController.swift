//
//  HistoryViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 24.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit
import SwiftChartView

class HistoryViewController: UIViewController {

	@IBOutlet weak var diagramImage: UIImageView!
	@IBOutlet weak var rangeSelector: UISegmentedControl!
	
	// MARK: IBActions
	@IBAction func displayRangeChanged(_ sender: Any) {
		switch rangeSelector.selectedSegmentIndex {
		case 0:
			diagram.analysisrange = .week
		case 1:
			diagram.analysisrange = .month
		default:
			diagram.analysisrange = .year
		}
		refreshRendering()
	}
	//properties
	private let diagram = Diagram()
	
	// MARK: functions
	func refreshRendering(){
		//let sortedDates = Model.shared.dataset.keys.sorted(by: {$0.compare($1) == .orderedDescending})
		
		//dataset to string
		diagramImage.image = diagram.getImage(frame: diagramImage.frame, scale: UIScreen.main.scale)
	}
	
	override func viewDidLoad() {
	}
	
	override func viewWillAppear(_ animated: Bool) {
		refreshRendering()
	}
}
