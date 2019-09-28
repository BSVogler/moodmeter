//
//  HistoryViewController.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 24.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import UIKit

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
    let diagramController = DiagramController()
    private let diagram: Diagram


    // MARK: IBOutlets
	@IBOutlet weak var diagramImage: UIImageView!
	@IBOutlet weak var rangeSelector: UISegmentedControl!
	@IBOutlet weak var rangeDisplay: UILabel!
	@IBOutlet weak var averageLabel: UILabel!
	
    // MARK: Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.diagram = Diagram(controller: diagramController)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshRendering), name: Measurement.changedNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        self.diagram = Diagram(controller: diagramController)
        super.init(coder: coder)
    }
    
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

	
    // MARK: Instance Methods
	@objc func refreshRendering(){
		//let sortedDates = Model.shared.dataset.keys.sorted(by: {$0.compare($1) == .orderedDescending})
        
        //dataset to string
        diagramImage.image = diagram.getImage(frame: diagramImage.frame, scale: UIScreen.main.scale)
        
        rangeDisplay.text = diagramController.getRangeText()
	}
}
