//
//  FaceRenderer.swift
//  moodassist
//
//  Created by Benedikt Stefan Vogler on 28.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation
import CoreGraphics
import UIKit

@IBDesignable
class FaceRenderer {
	
	public var scale = CGFloat(1)
	public var mood =  Mood(0)
	
	func getImage(frame: CGRect) -> UIImage {
		var centerY = frame.height/2
		let centerX = frame.width/2
		UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
		#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).setStroke()
		let eyeLeft = UIBezierPath.init(arcCenter: CGPoint(x: frame.width/4, y: centerY-15), radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		eyeLeft.lineWidth = 2;
		eyeLeft.fill()
		let eyeRight = UIBezierPath.init(arcCenter: CGPoint(x: frame.width*3/4, y: centerY-15), radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		eyeRight.lineWidth = 2;
		eyeRight.fill()
		
		let mouthPath = UIBezierPath()
		let quarter = frame.width/4
		switch mood {
		case 1:
			mouthPath.move(to: CGPoint(x:frame.width/4, y : centerY+80))
			mouthPath.addCurve(to: CGPoint(x:frame.width*3/4, y : centerY+80),
							   controlPoint1: CGPoint(x:centerX, y : centerY+40),
							   controlPoint2: CGPoint(x:centerX, y : centerY+40))
			mouthPath.addCurve(to: CGPoint(x:frame.width/4, y : centerY+80),
							   controlPoint1: CGPoint(x:centerX, y : centerY+50),
								 controlPoint2: CGPoint(x:centerX, y : centerY+50))
		case 2:
			mouthPath.move(to: CGPoint(x:frame.width/4, y : centerY+40))
			mouthPath.addLine(to: CGPoint(x:frame.width/4, y : centerY+40))
			mouthPath.addLine(to: CGPoint(x:frame.width*3/4, y : centerY+90))
			mouthPath.addLine(to: CGPoint(x:frame.width*3/4-20, y : centerY+90))
		case 3:
			mouthPath.move(to: CGPoint(x:frame.width/4, y : centerY+40))
			mouthPath.addLine(to: CGPoint(x:frame.width*3/4, y : centerY+40))
			mouthPath.addLine(to: CGPoint(x:frame.width*3/4, y : centerY+50))
			mouthPath.addLine(to: CGPoint(x:frame.width/4, y : centerY+50))
		case 4:
			centerY += quarter/2
			mouthPath.move(to: CGPoint(x:quarter, y : centerY))
			mouthPath.addCurve(to: CGPoint(x:3*quarter, y : centerY),
			controlPoint1: CGPoint(x:quarter+quarter/2, y : centerY+quarter*3/4),
			controlPoint2: CGPoint(x:3*quarter-quarter/2, y : centerY+quarter*3/4))
			mouthPath.addCurve(to: CGPoint(x:centerX, y : centerY+quarter*6/8),
							   controlPoint1: CGPoint(x:3*quarter, y : centerY+quarter/2),
							   controlPoint2: CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8))
			mouthPath.addCurve(to: CGPoint(x:centerX, y : centerY+quarter*6/8),
			controlPoint1: CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8),
			controlPoint2: CGPoint(x:centerX-quarter/2, y : centerY+quarter*6/8))
			mouthPath.addCurve(to: CGPoint(x:quarter, y : centerY),
							   controlPoint1: CGPoint(x:centerX-quarter/2, y : centerY+quarter*6/8),
							   controlPoint2: CGPoint(x:quarter, y : centerY+quarter/2))
		case 5:
			centerY += quarter/2
			mouthPath.move(to: CGPoint(x:quarter, y : centerY))
			mouthPath.addCurve(to: CGPoint(x:3*quarter, y : centerY),
			controlPoint1: CGPoint(x:quarter+quarter/2, y : centerY),
			controlPoint2: CGPoint(x:3*quarter-quarter/2, y : centerY))
			mouthPath.addCurve(to: CGPoint(x:centerX, y : centerY+quarter*6/8),
							   controlPoint1: CGPoint(x:3*quarter, y : centerY+quarter/2),
							   controlPoint2: CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8))
			mouthPath.addCurve(to: CGPoint(x:centerX, y : centerY+quarter*6/8),
			controlPoint1: CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8),
			controlPoint2: CGPoint(x:centerX-quarter/2, y : centerY+quarter*6/8))
			mouthPath.addCurve(to: CGPoint(x:quarter, y : centerY),
							   controlPoint1: CGPoint(x:centerX-quarter/2, y : centerY+quarter*6/8),
							   controlPoint2: CGPoint(x:quarter, y : centerY+quarter/2))
			
		default: break
		}
		
		mouthPath.close()
		mouthPath.fill()
		
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
}
