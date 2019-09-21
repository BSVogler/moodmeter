//
//  HistoryViewController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import WatchKit

enum AnalysisRange: Int {
	case week = 7
	case month = 30
	case year = 12
}

class HistoryInterfaceController: WKInterfaceController {
	
	@IBOutlet weak var diagram: WKInterfaceImage!
	@IBOutlet weak var label: WKInterfaceLabel!
	@IBOutlet weak var weekButton: WKInterfaceButton!
	@IBOutlet weak var monthButton: WKInterfaceButton!
	@IBOutlet weak var yearButton: WKInterfaceButton!
	
	var analysisrange = AnalysisRange.week
	
	
	@IBAction func weekButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
		analysisrange = .week
		redraw()
	}
	@IBAction func monthButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		analysisrange = .month
		redraw()
	}
	@IBAction func yearButtonTap() {
		monthButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		yearButton.setBackgroundColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
		weekButton.setBackgroundColor(#colorLiteral(red: 0.2162876725, green: 0.1914932728, blue: 0, alpha: 1))
		analysisrange = .year
		redraw()
	}
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		Model.shared.dataset[Date()] = 3
		redraw()
	}
	
	func redraw(){
		//let image = chart.draw(frame, scale: WKInterfaceDevice.current().screenScale)
		let frame = CGRect(x: 0, y: 0, width: self.contentFrame.width, height: 100)
		let image = getDiagram(frame: frame)
		self.diagram.setImage(image)
	}
	
	func getDiagram(frame: CGRect) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(frame.size, false, WKInterfaceDevice.current().screenScale);
		//let context = UIGraphicsGetCurrentContext()
		//context?.setFillColor(CGColor.init(srgbRed: 1, green: 0, blue: 1, alpha: 1))
		//context?.fill(frame)
		let axisColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		axisColor.setStroke()
		let offsettop = CGFloat(2)
		let offsettbottom = CGFloat(2)
		let offsetleft = CGFloat(2)
		let offsetright = CGFloat(2)
		let usedAreaHeight = frame.height-offsettop-offsettbottom
		let usedAreaWidth = frame.width-offsetleft-offsetright
		let tickHeight = usedAreaHeight/5.0
		for i in 1...5 {
			let ytick = UIBezierPath()
			let ypos = usedAreaHeight-CGFloat(i)*tickHeight+offsettop
			ytick.move(to: CGPoint(x:1, y: ypos))
			ytick.addLine(to: CGPoint(x:5, y: ypos))
			ytick.lineWidth = 1;
			ytick.stroke()
		}
		
		let yAxis = UIBezierPath()
		yAxis.move(to: CGPoint(x:1, y:offsettop))
		yAxis.addLine(to: CGPoint(x:1, y:frame.height-offsettbottom))
		yAxis.lineWidth = 1;
		yAxis.stroke()
		
		let xAxis = UIBezierPath()
		xAxis.move(to: CGPoint(x:0, y:frame.height-offsettbottom))
		xAxis.addLine(to: CGPoint(x:usedAreaWidth, y:frame.height-offsettbottom))
		xAxis.lineWidth = 1;
		xAxis.stroke()
		
		let tickWidth = usedAreaWidth / CGFloat(analysisrange.rawValue)
		for i in 1...analysisrange.rawValue {
			let tick = UIBezierPath()
			let xpos = CGFloat(i)*tickWidth
			tick.move(to: CGPoint(x:xpos, y: frame.height-offsettbottom))
			tick.addLine(to: CGPoint(x:xpos, y: frame.height-offsettbottom-4))
			tick.lineWidth = 1;
			tick.stroke()
		}
		
		//now draw the content
		let strokeColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
		strokeColor.setStroke()
		strokeColor.setFill()
		
		var points: [CGPoint] = []
		if analysisrange == .week {
			//get measurements for this week
			let lastWeekDay = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())
			if let lastWeekDay = lastWeekDay {
				let moods = Model.shared.dataset.filter{$0.key > lastWeekDay}.map{$0.value}
				let points2 = moods.enumerated().map { (i, mood) in CGPoint(x: CGFloat(i)*tickWidth,y: CGFloat(tickHeight)*CGFloat(mood))}
				points.append(contentsOf: points2)
			}
		}
		
		//draw points and connect them
		var lastpoint: CGPoint? = nil
		let path = UIBezierPath()
		for point in points {
			let circle = UIBezierPath.init(arcCenter: point, radius: 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
			circle.lineWidth = 2;
			circle.fill()
			if lastpoint==nil {
				lastpoint = point
				path.move(to: point)
			} else {
				path.addLine(to: point)
			}
		}
		path.lineWidth = 2;
		path.stroke()
		
		
		let image2 = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return image2
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
}
