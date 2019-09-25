//
//  HistoryViewController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import WatchKit



class HistoryInterfaceController: WKInterfaceController {
	
	@IBOutlet weak var diagramImage: WKInterfaceImage!
	@IBOutlet weak var label: WKInterfaceLabel!
	@IBOutlet weak var weekButton: WKInterfaceButton!
	@IBOutlet weak var monthButton: WKInterfaceButton!
	@IBOutlet weak var yearButton: WKInterfaceButton!
	
	let diagram = Diagram()
	
	@IBAction func weekButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
		diagram.analysisrange = .week
		redraw()
	}
	@IBAction func monthButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		diagram.analysisrange = .month
		redraw()
	}
	@IBAction func yearButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		diagram.analysisrange = .year
		redraw()
	}
	
	@IBAction func navigateBack() {
		diagram.navigateBack()
		redraw()
	}
	
	@IBAction func navigateForward() {
		diagram.navigateForward()
		redraw()
	}
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		redraw()
	}
	
	func redraw(){
		//let image = chart.draw(frame, scale: WKInterfaceDevice.current().screenScale)
		let image = diagram.getImage(frame: self.contentFrame, scale: WKInterfaceDevice.current().screenScale)
		self.diagramImage.setImage(image)
	}
	
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
}
