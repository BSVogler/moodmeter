//
//  HistoryViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 24.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

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
	
	func refreshRendering(){
		let sortedDates = Model.shared.dataset.keys.sorted(by: {$0.compare($1) == .orderedDescending})
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		
		let lines = sortedDates.map {
			return formatter.string(from:$0)+" "+(Model.shared.dataset[$0]?.getSmiley() ?? "")
		}
		historyLabel.text = lines.joined(separator: "\n")
	}
	
	override func viewDidLoad() {
		diagram.chartPoints = chartPoints
		diagram.pointStyle = .circle
	}
	
	override func viewWillAppear(_ animated: Bool) {
		refreshRendering()
	}
}
