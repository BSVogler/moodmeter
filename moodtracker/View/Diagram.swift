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
			tickHeight = usedAreaHeight / 5.0
			tickWidth = usedAreaWidth / CGFloat(analysisrange.rawValue)
		}
	}
	var usedAreaHeight =  CGFloat(0)
	var usedAreaWidth = CGFloat(0)
	var tickHeight = CGFloat(0)
	var tickWidth = CGFloat(0)
	var analysisrange = AnalysisRange.week{
		didSet {
			updateBounds()
		}
	}
	var selectedDate = Date(){
		didSet {
			updateBounds()
		}
	}
	var lowerDate: Date? = Date()
	var higherDate: Date? = Date()
	
    // MARK: Initializers
	init() {
		updateBounds()
	}
	
    // MARK: Instance Methods
	func navigateBack() {
		switch analysisrange {
		case .week:
			selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate) ?? selectedDate
		case .month:
			selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
		case .year:
			selectedDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedDate) ?? selectedDate
		}
	}
	
	func navigateForward(){
		switch analysisrange {
		case .week:
			selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
		case .month:
			selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
		case .year:
			selectedDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate) ?? selectedDate
		}
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
	
    // MARK: Private Instance Methods
	private func drawBackground() {
		for (i, color) in MoodConstants.moodToColor.suffix(from: 1).reversed().enumerated() {
			color.setFill()
			UIRectFill(CGRect(x: offsetleft, y: offsettop+CGFloat(i)*tickHeight, width: usedAreaWidth, height: usedAreaHeight/5))
		}
	}
	
	private func drawAxis() {
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
		
		// get label description
		var labels: [String] = []
		switch analysisrange {
		case .week:
			var calendar = Calendar(identifier: .gregorian)
			calendar.locale = Locale.current
			labels = calendar.weekdaySymbols.map{String($0.prefix(3))}
		case .month:
			labels = ["1","8", "15", "21","28"]
		case .year:
			var calendar = Calendar(identifier: .gregorian)
			calendar.locale = Locale.current
			labels = calendar.monthSymbols.map{String($0.prefix(3))}
		}
		
		// draw dashes
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
	
	private func getPoints() -> [CGPoint] {
		var points: [CGPoint] = []
		switch analysisrange {
		case .week:
			// get measurements for this week
			if let lowerDate = lowerDate,
			   let higherDate = higherDate {
                let measurements = DataHandler.userProfile.dataset
                    .filter({ $0.day > lowerDate && $0.day < higherDate })
                    .sorted(by: { $0.day < $1.day })
                
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
			if let lowerDate = lowerDate,
			   let higherDate = higherDate {
				let measurements = DataHandler.userProfile.dataset
                .filter({ $0.day > lowerDate && $0.day < higherDate })
                .sorted(by: { $0.day < $1.day })
				points = measurements.enumerated().map { (i, measurement) -> CGPoint in
					let intervalSinceFirst = measurement.day.timeIntervalSince(lowerDate)
					let daysSinceMonth = floor(intervalSinceFirst / (3600*24))
					let x: CGFloat = offsetleft+CGFloat(daysSinceMonth)*tickWidth+CGFloat(0.5)*tickWidth
					let y: CGFloat = frame.height+tickHeight/2-offsettbottom-CGFloat(tickHeight)*CGFloat(measurement.mood)
					return CGPoint(x: x, y: y)
				}.sorted{$0.x > $1.x}
			}
		case .year:
			for month in 1...12 {
				var dateComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
				dateComponents.month = month
				let lowerDateMonth = Calendar.current.date(from:dateComponents)
				if let lowerDateMonth = lowerDateMonth,
				   let higherDateMonth = Calendar.current.date(byAdding: .month, value: 1, to: lowerDateMonth) {
                    
                    let datesInMonth = DataHandler.userProfile.dataset.filter{ $0.day > lowerDateMonth && $0.day < higherDateMonth }
                    
					if datesInMonth.count > 0 {
						let avgMood = datesInMonth.reduce(0) { $0 + $1.mood } / datesInMonth.count
						let x: CGFloat = offsetleft+CGFloat(month)*tickWidth+CGFloat(0.5)*tickWidth
						let y: CGFloat = frame.height+tickHeight/2-offsettbottom-CGFloat(tickHeight)*CGFloat(avgMood)
						points.append(CGPoint(x: x, y: y))
					}
				}
			}
		}
		return points
	}
	
	private func drawPath(){
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
    
    private func updateBounds(){
        let calendar = Calendar.current
        switch analysisrange {
        case .week:
            lowerDate = selectedDate.previous(.monday)
            higherDate = selectedDate.next(.monday)
        case .month:
            let firstComponents = calendar.dateComponents([.year, .month], from: selectedDate)
            lowerDate = calendar.date(from: firstComponents)
            var nextComponents = DateComponents()
            nextComponents.month = 1
            higherDate = calendar.date(byAdding: nextComponents, to: selectedDate)
        case .year:
            let dateComponents = calendar.dateComponents([.year], from: selectedDate)
            lowerDate = calendar.date(from: dateComponents)
            if let lowerDate = lowerDate {
                higherDate = calendar.date(byAdding: .year, value: 1, to: lowerDate)
            }
        }
    }
}
