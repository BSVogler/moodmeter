//
//  Diagram.swift
//  moodtracker
//
//  Created by Benedikt Stefan Vogler on 24.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

enum AnalysisRange: Int {
	case week = 7
	case month = 30
	case year = 12
}

class Diagram {
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
			tickWidth = usedAreaWidth / CGFloat(analysisrange.rawValue)
		}
	}
	var usedAreaHeight =  CGFloat(0)
	var usedAreaWidth = CGFloat(0)
	var tickHeight = CGFloat(0)
	var tickWidth = CGFloat(0)
	var analysisrange = AnalysisRange.week
	
	init() {
		
	}
	
	func getImage(frame: CGRect, scale: CGFloat) -> UIImage {
		self.frame = frame
		UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
		axisColor.setStroke()
		//let context = UIGraphicsGetCurrentContext()
		//context?.setFillColor(CGColor.init(srgbRed: 1, green: 0, blue: 1, alpha: 1))
		//context?.fill(frame)
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
		let yAxis = UIBezierPath()
		yAxis.move(to: CGPoint(x:offsetleft, y:offsettop))
		yAxis.addLine(to: CGPoint(x:offsetleft, y:frame.height-offsettbottom))
		yAxis.lineWidth = 1;
		yAxis.stroke()
		
		let xAxis = UIBezierPath()
		xAxis.move(to: CGPoint(x:offsetleft, y:frame.height-offsettbottom))
		xAxis.addLine(to: CGPoint(x:offsetleft+usedAreaWidth, y:frame.height-offsettbottom))
		xAxis.lineWidth = 1;
		xAxis.stroke()
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 12)!,
					 NSAttributedString.Key.paragraphStyle: paragraphStyle,
					 NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)]
		
		//get label description
		var labels: [String] = []
		switch analysisrange {
		case .week:
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "EEEE"
			var dateComponents = DateComponents()
			for month in 1..<8 {
				//starting from a monday
				dateComponents.year = 2019
				dateComponents.month = 4
				dateComponents.day = month
				if let date = Calendar.current.date(from: dateComponents) {
					let weekday = dateFormatter.string(from: date).prefix(3).capitalized
					labels.append(weekday)
				}
			}
		case .month:
			labels = ["1","8", "15", "21","28"]
		case .year:
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMMM"
			var dateComponents = DateComponents()
			for month in 1...12 {
				dateComponents.month = month
				if let date = Calendar.current.date(from: dateComponents) {
					let monthShort = dateFormatter.string(from: date).capitalized
					labels.append(String(monthShort.first!))
				}
			}
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
		let unitFlags:Set<Calendar.Component> = [.hour, .day, .month, .year,.minute,.hour,.second, .calendar]
		switch analysisrange {
		case .week:
			//get measurements for this week
			//todo, needs the days since monday
			let lastWeekDay = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())
			if let lastWeekDay = lastWeekDay {
				let moods = Model.shared.dataset.filter{$0.key > lastWeekDay}.reversed().map{$0.value}
				points = moods.enumerated().map { (arg) -> CGPoint in
					let (i, mood) = arg
					let x: CGFloat = offsetleft+CGFloat(i)*tickWidth+CGFloat(0.5)*tickWidth
					let y: CGFloat = frame.height+tickHeight/2-offsettbottom-CGFloat(tickHeight)*CGFloat(mood)
					return CGPoint(x: x, y: y)
				}
			}
		case .month:
			var dateComponents = Calendar.current.dateComponents(unitFlags, from: Date())
			dateComponents.day = 1
			//get measurements for this week
			if let firstDayMonth = dateComponents.date {
				let moods = Model.shared.dataset.filter{$0.key > firstDayMonth}.reversed().map{$0.value}
				points = moods.enumerated().map { (arg) -> CGPoint in
					let (i, mood) = arg
					let x: CGFloat = offsetleft+CGFloat(i)*tickWidth+CGFloat(0.5)*tickWidth
					let y: CGFloat = frame.height+tickHeight/2-offsettbottom-CGFloat(tickHeight)*CGFloat(mood)
					return CGPoint(x: x, y: y)
				}
			}
		case .year:
			for month in 1...12 {
				var dateComponents = Calendar.current.dateComponents(unitFlags, from: Date())
				dateComponents.day = 1
				dateComponents.month = month
				var dateComponentsNext = Calendar.current.dateComponents(unitFlags, from: Date())
				dateComponentsNext.day = 1
				dateComponentsNext.month = month+1
				//get measurements for this week
				if let currentMonth = dateComponents.date,
					let nextMonth = dateComponentsNext.date {
					let datesinMonth = Model.shared.dataset.filter{$0.key > currentMonth && $0.key < nextMonth }
					if datesinMonth.count > 0 {
						let avgmood = datesinMonth.reduce(0) { $0 + $1.value } / datesinMonth.count
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
		path.lineWidth = 2
		path.stroke()
	}
}
