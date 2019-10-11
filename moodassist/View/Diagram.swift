//
//  Diagram.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 24.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import CoreGraphics
import UIKit

// MARK: - Enum AnalysisRange
enum AnalysisRange: Int {
	case week = 7
	case month = 30
	case year = 12
}

// MARK: - Diagram
class Diagram {
    
    // MARK: Stored Instance Properties
	let axisColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
	let offsettop = CGFloat(2)
	let offsettbottom = CGFloat(15)
	let offsetleft = CGFloat(1)
	let offsetright = CGFloat(2)
	var frame: CGRect = CGRect.zero {
		didSet {
			usedAreaHeight = frame.height-offsettop-offsettbottom
			usedAreaWidth = frame.width-offsetleft-offsetright
			tickHeight = usedAreaHeight/5.0
			tickWidth = usedAreaWidth / CGFloat(controller.analysisrange.rawValue)
		}
	}
	var usedAreaHeight =  CGFloat(0)
	var usedAreaWidth = CGFloat(0)
	var tickHeight = CGFloat(0)
	var tickWidth = CGFloat(0)
	var controller: DiagramController
	var dotSize: CGFloat = 4
	
	init(controller: DiagramController){
		self.controller = controller
	}
	// MARK: Instance Methods
	
	func getImage(scale: CGFloat) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
		axisColor.setStroke()
		drawBackground()
		drawAxis()
		drawPath()
		
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
	func drawBackground(){
		for (i, color) in Measurement.moodToColor.suffix(from: 1).reversed().enumerated() {
			color.setFill()
			UIRectFill(CGRect(x: offsetleft, y: offsettop+CGFloat(i)*tickHeight, width: usedAreaWidth, height: usedAreaHeight/5))
		}
	}
	
	func drawAxis(){
		let xAxis = UIBezierPath()
		xAxis.move(to: CGPoint(x:offsetleft, y:frame.height-offsettbottom))
		xAxis.addLine(to: CGPoint(x:offsetleft+usedAreaWidth, y:frame.height-offsettbottom))
		xAxis.lineWidth = 1;
		xAxis.stroke()
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 12)!,
					 NSAttributedString.Key.paragraphStyle: paragraphStyle,
					 NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)]
		
		//get label description
		var labels: [String] = []
		switch controller.analysisrange {
		case .week:
			var calendar = Calendar(identifier: .gregorian)
			calendar.locale = Locale.current
			labels = calendar.weekdaySymbols.map{String($0.prefix(3))}
			//sunday should be last day of the week
			labels.append(labels[0])
			labels.remove(at: 0)
		case .month:
			labels = ["1","8", "15", "21","28"]
		case .year:
			var calendar = Calendar(identifier: .gregorian)
			calendar.locale = Locale.current
			labels = calendar.monthSymbols.map{String($0.prefix(3))}
		}
		
		//draw dasges
		let dashes: [ CGFloat ] = [ 3.0, 2.0 ]
		let tickWidth = usedAreaWidth / CGFloat(labels.count)
		for i in 1..<labels.count {
			let tick = UIBezierPath()
			tick.setLineDash(dashes, count: dashes.count, phase: 0.0)
			tick.lineCapStyle = .round
			let xpos = CGFloat(i)*tickWidth
			tick.move(to: CGPoint(x:xpos, y: frame.height))
			tick.addLine(to: CGPoint(x:xpos, y:0))
			tick.lineWidth = 0.8;
			tick.stroke()
		}
		//draw labels
		for (index, label) in labels.enumerated() {
			label.draw(with: CGRect(x: CGFloat(index)*tickWidth, y: frame.height-offsettbottom, width: tickWidth, height: offsettbottom), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
		}
	}
	
	func getPoints() -> [CGPoint] {
		var points: [CGPoint] = []
		switch controller.analysisrange {
		case .week:
			//get measurements for this week
			if let lowerDate = controller.lowerDate,
				let higherDate = controller.higherDate {
				let measurements = Model.shared.measurements.filter{$0.day > lowerDate && $0.day < higherDate}
				points = measurements.enumerated().map { (i, measurement) -> CGPoint in
					let intervalSinceFirst = measurement.day.timeIntervalSince(lowerDate)
					let daysSinceMonth = floor(intervalSinceFirst / (3600*24))
					let x: CGFloat = offsetleft+CGFloat(daysSinceMonth)*tickWidth+CGFloat(0.5)*tickWidth
					let y: CGFloat = frame.height+tickHeight/2-offsettbottom-CGFloat(tickHeight)*CGFloat(measurement.mood)
					return CGPoint(x: x, y: y)
				}.sorted{$0.x > $1.x}
			}
		case .month:
			//get measurements for this month
			//dateComponents.month = Calendar.current.component(Calendar.Component.month, from: selectedDate)
			if let lowerDate = controller.lowerDate,
				let higherDate = controller.higherDate {
				let measurements = Model.shared.measurements.filter{$0.day > lowerDate && $0.day < higherDate}
				points = measurements.enumerated().map { (i, measurement) -> CGPoint in
					let intervalSinceFirst = measurement.day.timeIntervalSince(lowerDate)
					let daysSinceMonth = floor(intervalSinceFirst / (3600*24))
					let x: CGFloat = offsetleft+CGFloat(daysSinceMonth)*tickWidth+CGFloat(0.5)*tickWidth
					let y: CGFloat = frame.height+tickHeight/2-offsettbottom-CGFloat(tickHeight)*CGFloat(measurement.mood)
					return CGPoint(x: x, y: y)
				}.sorted{$0.x > $1.x}
			}
		case .year:
			var dateComponents = Calendar.current.dateComponents([.year, .month], from: controller.selectedDate)
			let measurements = Model.shared.measurements;
			for month in 1...12 {
				dateComponents.month = month
				if let lowerDateMonth = Calendar.current.date(from:dateComponents),
					let higherDateMonth = Calendar.current.date(byAdding: .month, value: 1, to: lowerDateMonth) {
					let datesinMonth = measurements.filter {$0.day > lowerDateMonth && $0.day < higherDateMonth }//transform the js dates to date objects
					if datesinMonth.count > 0 {
						let avgmood = datesinMonth.reduce(0) { $0 + $1.mood } / datesinMonth.count
						let x: CGFloat = offsetleft+CGFloat(month)*tickWidth+CGFloat(0.5)*tickWidth
						let y: CGFloat = frame.height+tickHeight/2-offsettbottom-CGFloat(tickHeight)*CGFloat(avgmood)
						points.append(CGPoint(x: x, y: y))
					}
				}
			}
		}
		return points
	}
	
	func drawPath(){
		//now draw the content
		let strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		strokeColor.setStroke()
		strokeColor.setFill()
		
		let points = getPoints()
		if points.count == 0 {
			return
		}
		//draw average line
		let averageColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
		averageColor.setStroke()
		averageColor.setFill()
		let avgLine = UIBezierPath()
		avgLine.setLineDash([ 3.0, 2.0 ], count: 2, phase: 0.0)
		avgLine.lineCapStyle = .round
		let average = points.reduce(0){$0+$1.y}/CGFloat(points.count)
		avgLine.move(to: CGPoint(x: 0,y:average))
		avgLine.addLine(to: CGPoint(x:frame.width,y:average))
		avgLine.stroke()
		
		let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 12)!,
		NSAttributedString.Key.foregroundColor: averageColor]
		"⌀".draw(with: CGRect(x: frame.width*0.90, y: average, width: tickWidth*1.5, height: offsettbottom),
				   options: .usesDeviceMetrics, attributes: attrs, context: nil)
		
		//draw points and connect them
		var lastpoint: CGPoint? = nil
		let path = UIBezierPath()
		for point in points {
			let circle = UIBezierPath.init(arcCenter: point, radius: dotSize, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
			circle.lineWidth = 2;
			circle.fill()
			if lastpoint==nil {
				lastpoint = point
				path.move(to: point)
			} else {
				path.addLine(to: point)
			}
		}
		path.lineWidth = 2
		path.lineJoinStyle = .round
		path.stroke()
	}
}
