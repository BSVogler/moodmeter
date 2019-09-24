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
	
	@IBAction func displayRangeChanged(_ sender: Any) {
		
	}
	
	private lazy var chartPoints: [ChartPoint] = {
		var chartPoints: [ChartPoint] = []
		let moods = Model.shared.measurements.map{$0.mood}
		for i in 0 ..< moods.count {
			let chartPoint = ChartPoint(label: "11-0\(i+1)", value: Double(moods[i])/5.0)
			chartPoints.append(chartPoint)
		}
		return chartPoints
	}()
	
	func refreshRendering(){
		let sortedDates = Model.shared.dataset.keys.sorted(by: {$0.compare($1) == .orderedDescending})
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		
		//dataset to string
		let diagram = Diagram(frame: diagramImage.frame, analysisrange: .week)
		diagramImage.image = diagram.getImage(scale: UIScreen.main.scale)
	}
	
	override func viewDidLoad() {
	}
	
	override func viewWillAppear(_ animated: Bool) {
		refreshRendering()
	}
}
