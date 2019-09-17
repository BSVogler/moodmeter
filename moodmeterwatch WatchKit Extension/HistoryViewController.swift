//
//  HistoryViewController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import WatchKit
import YOChartImageKit

class HistoryInterfaceController: WKInterfaceController {
	
	@IBOutlet weak var diagram: WKInterfaceImage!
	@IBOutlet weak var label: WKInterfaceLabel!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		//connect the watchkit scene with the scene outlet
		
		let chart = YOLineChartImage()
		chart.strokeWidth = 3.0
		chart.strokeColor = UIColor.red
		
		chart.values = Model.shared.dataset.map {return NSNumber(value: $0.value)}
		chart.smooth = false
		
		let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
		let image = chart.draw(frame, scale: WKInterfaceDevice.current().screenScale)
		self.diagram.setImage(image)
	}
	
	func getDiagram(frame: CGRect) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(frame.size, false, 1);
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(CGColor.init(srgbRed: 1, green: 0, blue: 0, alpha: 1))
		context?.fill(frame)
		let strokeColor = UIColor.blue
		//let path = UIBezierPath()
		//path.addLine(to: CGPoint(x:30,y:30))
		//path.addLine(to: CGPoint(x:70,y:70))
		//path.lineWidth = 2;
		strokeColor.setStroke()
		//path.stroke()

		let image2 = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return image2
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
}
