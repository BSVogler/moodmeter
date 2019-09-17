//
//  HistoryViewController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import WatchKit

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
		let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
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

		var image2 = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		self.diagram.setImage(image2)
		//self.diagram.setHidden(true)
		//setting this label makes the button dissapear
		label.setText("lol")
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
}
