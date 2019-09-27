//
//  HistoryViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 24.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import UIKit
import SwiftChartView

// MARK: HistoryViewController
class HistoryViewController: UIViewController {
	
    // MARK: Constants
    private enum Constants {
        static let formatterWeek: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM YY"
            formatter.locale = Calendar.current.locale
            return formatter
        }()
        static let formatterMonth: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM YYYY"
            formatter.locale = Calendar.current.locale
            return formatter
        }()
    }
    
    // MARK: Stored Instance Properties
    private let diagram = Diagram()

    // MARK: IBOutlets
	@IBOutlet weak var diagramImage: UIImageView!
	@IBOutlet weak var rangeSelector: UISegmentedControl!
	@IBOutlet weak var rangeDisplay: UILabel!
	@IBOutlet weak var averageLabel: UILabel!
	
    // Overridden/ Lifecycle Methods
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshRendering()
    }
    
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
	
	@IBAction func navigateForward(_ sender: Any) {
		diagram.navigateForward()
		refreshRendering()
	}
	
	@IBAction func navigateBackwards(_ sender: Any) {
		diagram.navigateBack()
		refreshRendering()
	}
	
	// MARK: Private Instance Methods
	private func refreshRendering(){
		//let sortedDates = Model.shared.dataset.keys.sorted(by: {$0.compare($1) == .orderedDescending})
		
		//dataset to string
		diagramImage.image = diagram.getImage(frame: diagramImage.frame, scale: UIScreen.main.scale)
		
		switch diagram.analysisrange {
		case .year:
			let dateComponents = Calendar.current.dateComponents([.year], from: diagram.selectedDate)
			rangeDisplay.text = "\(dateComponents.year!)"
		case .week:
			if let lower = diagram.lowerDate,
				let higher = diagram.higherDate {
                rangeDisplay.text = "\(Constants.formatterWeek.string(from: lower)) - \(Constants.formatterWeek.string(from: higher))"
			}
		case .month:
            rangeDisplay.text = "\(Constants.formatterMonth.string(from: diagram.selectedDate))"
		}
	}

}
