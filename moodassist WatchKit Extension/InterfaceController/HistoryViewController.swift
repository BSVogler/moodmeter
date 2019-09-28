//
//  HistoryViewController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import WatchKit

// MARK: HistoryInterfaceController
class HistoryInterfaceController: WKInterfaceController {
	
    // MARK: Stored Instance Properties
    let diagramController = DiagramController()
    let diagram: Diagram
    
	// MARK: IBOutlets
	@IBOutlet weak var diagramImage: WKInterfaceImage!
	@IBOutlet weak var weekButton: WKInterfaceButton!
	@IBOutlet weak var monthButton: WKInterfaceButton!
	@IBOutlet weak var yearButton: WKInterfaceButton!
	@IBOutlet weak var rangeLabel: WKInterfaceLabel!
	
    // MARK: Initializers
    override init() {
        diagram = Diagram(controller: diagramController)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.redraw), name: Measurement.changedNotification, object: nil)
    }
    
    // MARK: Overridden/ Lifecycle Methods
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        redraw()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
	// MARK: IBActions
	@IBAction func weekButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.9479486346, green: 0.6841028333, blue: 0, alpha: 1))
		diagramController.analysisRange = .week
		redraw()
	}
    
	@IBAction func monthButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.9479486346, green: 0.6841028333, blue: 0, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		diagramController.analysisRange = .month
		redraw()
	}
    
	@IBAction func yearButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.9479486346, green: 0.6841028333, blue: 0, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		diagramController.analysisRange = .year
		redraw()
	}
	
	@IBAction func navigateBack() {
		diagramController.navigateBack()
		redraw()
	}
	
	@IBAction func navigateForward() {
		diagramController.navigateForward()
		redraw()
	}
	
	// MARK: Instance Methods
	@objc func redraw(){
		//let image = chart.draw(frame, scale: WKInterfaceDevice.current().screenScale)
		let image = diagram.getImage(frame: self.contentFrame, scale: WKInterfaceDevice.current().screenScale)
		self.diagramImage.setImage(image)
		rangeLabel.setText(diagramController.getRangeText())
	}
}
