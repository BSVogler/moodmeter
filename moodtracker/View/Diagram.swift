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
	let frame: CGRect
	let axisColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
	let offsettop = CGFloat(2)
	let offsettbottom = CGFloat(2)
	let offsetleft = CGFloat(1)
	let offsetright = CGFloat(2)
	let usedAreaHeight: CGFloat
	let usedAreaWidth: CGFloat
	let tickHeight: CGFloat
	let tickWidth: CGFloat
	let analysisrange: AnalysisRange

	init(frame: CGRect, analysisrange: AnalysisRange){
		self.frame = frame
		usedAreaHeight = frame.height-offsettop-offsettbottom
		usedAreaWidth = frame.width-offsetleft-offsetright
		tickHeight = usedAreaHeight/5.0
		tickWidth = usedAreaWidth / CGFloat(analysisrange.rawValue)
		self.analysisrange = analysisrange
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
		
		for i in 1...analysisrange.rawValue {
			let tick = UIBezierPath()
			let xpos = CGFloat(i)*tickWidth
			tick.move(to: CGPoint(x:xpos, y: frame.height-offsettbottom))
			tick.addLine(to: CGPoint(x:xpos, y: frame.height-offsettbottom-4))
			tick.lineWidth = 1;
			tick.stroke()
		}
	}
	
	func getImage(scale: CGFloat) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
		axisColor.setStroke()
		//let context = UIGraphicsGetCurrentContext()
		//context?.setFillColor(CGColor.init(srgbRed: 1, green: 0, blue: 1, alpha: 1))
		//context?.fill(frame)
		drawBackground()
		drawAxis()
		//		for i in 1...5 {
		//			let ytick = UIBezierPath()
		//			let ypos = usedAreaHeight-CGFloat(i)*tickHeight+offsettop
		//			ytick.move(to: CGPoint(x:1, y: ypos))
		//			ytick.addLine(to: CGPoint(x:5, y: ypos))
		//			ytick.lineWidth = 1;
		//			ytick.stroke()
		//		}
		
		
		//now draw the content
		let strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		strokeColor.setStroke()
		strokeColor.setFill()
		
		var points: [CGPoint] = []
		if analysisrange == .week {
			//get measurements for this week
			let lastWeekDay = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())
			if let lastWeekDay = lastWeekDay {
				let moods = Model.shared.dataset.filter{$0.key > lastWeekDay}.reversed().map{$0.value}
				let points2 = moods.enumerated().map { (i, mood) in CGPoint(x: offsetleft+CGFloat(i)*tickWidth, y: frame.height+tickHeight/2-offsettbottom-CGFloat(tickHeight)*CGFloat(mood))}
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
		path.lineWidth = 2
		path.stroke()
		
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
}
