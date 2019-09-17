//
//  HistoryViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 24.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

	@IBOutlet weak var historyLabel: UILabel!
	
	func refreshRendering(){
		let sortedDates = Model.shared.dataset.keys.sorted(by: {$0.compare($1) == .orderedDescending})
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		
		let lines = sortedDates.map {
			return formatter.string(from:$0)+" "+Face.getSmiley(mood: Model.shared.dataset[$0]!)
		}
		historyLabel.text = lines.joined(separator: "\n")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		refreshRendering()
	}
}
