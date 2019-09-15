//
//  AnalysisViewController.swift
//  Moodmeter
//
//  Created by Benedikt Stefan Vogler on 15.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit
import SwiftChartView

class AnalysisViewController: UIViewController {

	@IBOutlet weak var diagram: LineChartView!
	private lazy var chartPoints: [ChartPoint] = {
		var chartPoints: [ChartPoint] = []
		let moods = Model.shared.measurements.map{$0.mood}
		for i in 0 ..< moods.count {
			let chartPoint = ChartPoint(label: "11-0\(i+1)", value: Double(moods[i])/5.0)
			chartPoints.append(chartPoint)
		}
		return chartPoints
	}()
	
	override func viewDidLoad() {
		diagram.chartPoints = chartPoints
		diagram.pointStyle = .circle
	}
}
