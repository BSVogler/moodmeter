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
	public var offsetX = CGFloat(0)
	public var offsetY = CGFloat(0)
	
	private func newFace(rect: CGRect){
		let centerY = rect.height/2+offsetY
		UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
		#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).setStroke()
		let eyeLeft = UIBezierPath.init(arcCenter: CGPoint(x: rect.width/4, y: centerY-15), radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		eyeLeft.lineWidth = 2;
		eyeLeft.fill()
		let eyeRight = UIBezierPath.init(arcCenter: CGPoint(x: rect.width*3/4, y: centerY-15), radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
		eyeRight.lineWidth = 2;
		eyeRight.fill()
	}
	
	private func drawPath(pF: [CGPoint],cpF: [CGPoint?],pT: [CGPoint],cpT: [CGPoint?], interpolation: Float){
		let mouthPath = UIBezierPath()
		let interpolp = CGPoint(
			x: pF[0].x+(pT[0].x-pF[0].x)*CGFloat(interpolation),
			y: pF[0].y+(pT[0].y-pF[0].y)*CGFloat(interpolation))
		mouthPath.move(to:interpolp)
		for i in 1..<pF.count {
			let cp1F = cpF[i*2-2] ?? pF[i-1]
			let cp2F = cpF[i*2-1] ?? pF[i]
			let cp1T = cpT[i*2-2] ?? pT[i-1]
			let cp2T = cpT[i*2-1] ?? pT[i]
			let cp1 = CGPoint(
				x: cp1F.x+(cp1T.x-cp1F.x)*CGFloat(interpolation),
				y: cp1F.y+(cp1T.y-cp1F.y)*CGFloat(interpolation))
			let cp2 = CGPoint(
				x: cp2F.x+(cp2T.x-cp2F.x)*CGFloat(interpolation),
				y: cp2F.y+(cp2T.y-cp2F.y)*CGFloat(interpolation))
			//because we already did the first
			let interpolp = CGPoint( x: pF[i].x+(pT[i].x-pF[i].x)*CGFloat(interpolation),
									 y: pF[i].y+(pT[i].y-pF[i].y)*CGFloat(interpolation))
			mouthPath.addCurve(to: interpolp, controlPoint1: cp1, controlPoint2: cp2)
		}
		//close
		let cp1F = cpF[cpF.count-2] ?? pF[0]
		let cp2F = cpF[cpF.count-1] ?? pF[0]
		let cp1T = cpT[cpT.count-2] ?? pT[0]
		let cp2T = cpT[cpT.count-1] ?? pT[0]
		let cp1 = CGPoint(
			x: cp1F.x+(cp1T.x-cp1F.x)*CGFloat(interpolation),
			y: cp1F.y+(cp1T.y-cp1F.y)*CGFloat(interpolation))
		let cp2 = CGPoint(
			x: cp2F.x+(cp2T.x-cp2F.x)*CGFloat(interpolation),
			y: cp2F.y+(cp2T.y-cp2F.y)*CGFloat(interpolation))
		mouthPath.addCurve(to: interpolp, controlPoint1: cp1, controlPoint2: cp2)
		//mouthPath.close()
		mouthPath.fill()
	}
	
	func getAnimation(rect: CGRect, from: Int, to: Int) -> [UIImage] {
		var images: [UIImage] = []
		if to > 0 && from > 0 {
			let pF = getPoints(rect: rect,mood: from)
			let cpF = getControlPoints(rect: rect, mood: from)
			let pT = getPoints(rect: rect,mood: to)
			let cpT = getControlPoints(rect: rect, mood: to)
			for i in 0...8 {
				newFace(rect: rect)
				drawPath(pF: pF,cpF: cpF,pT: pT,cpT: cpT, interpolation: Float(i)/8.0)
				let image = UIGraphicsGetImageFromCurrentImageContext()!
				UIGraphicsEndImageContext()
				images.append(image)
			}
		} else {
			newFace(rect: rect)
			let image = UIGraphicsGetImageFromCurrentImageContext()!
			UIGraphicsEndImageContext()
			images.append(image)
		}
		
		return images
	}
	
	private func getPoints(rect: CGRect, mood: Int) -> [CGPoint] {
		let centerX = rect.width/2+offsetX
		var centerY = rect.height/2+offsetY
		var points: [CGPoint] = []
		let quarter = rect.width/4
		switch mood {
			case 1:
				points.append(CGPoint(x:rect.width/4, y: centerY+quarter))
				points.append(CGPoint(x:rect.width/4, y: centerY+quarter))
				points.append(CGPoint(x:rect.width*3/4, y: centerY+quarter))
				points.append(CGPoint(x:rect.width*3/4, y: centerY+quarter))
			case 2:
				points.append(CGPoint(x:quarter, y: centerY+quarter/2))
				points.append(CGPoint(x:quarter+quarter/4, y: centerY+quarter/2))
				points.append(CGPoint(x:rect.width*3/4, y: centerY+quarter))
				points.append(CGPoint(x:rect.width*3/4-quarter/2, y: centerY+quarter))
			case 3:
				points.append(CGPoint(x:quarter, y: centerY+quarter/4))
				points.append(CGPoint(x:centerX+quarter, y: centerY+quarter/4))
				points.append(CGPoint(x:centerX+quarter, y: centerY+quarter/3))
				points.append(CGPoint(x:quarter, y: centerY+quarter/3))
			case 4:
				centerY += quarter/2
				points.append(CGPoint(x:quarter-quarter/2, y: centerY))
				points.append(CGPoint(x:3*quarter+quarter/2, y: centerY))
				points.append(CGPoint(x:centerX, y: centerY+quarter*6/8))
				points.append(CGPoint(x:centerX, y: centerY+quarter*6/8))
			case 5:
				centerY += quarter/2
				points.append(CGPoint(x:quarter, y: centerY))
				points.append(CGPoint(x:3*quarter, y: centerY))
				points.append(CGPoint(x:centerX, y: centerY+quarter*6/8))
				points.append(CGPoint(x:centerX, y: centerY+quarter*6/8))
			default: break
			}
		return points
	}
	
	private func getControlPoints(rect: CGRect, mood: Int) -> [CGPoint?] {
		let centerX = rect.width/2+offsetX
		var centerY = rect.height/2+offsetY
		var points: [CGPoint?] = []
		let quarter = rect.width/4
		switch mood {
			case 1:
				points.append(nil)
				points.append(nil)
				points.append(CGPoint(x:centerX, y: centerY+quarter/2))
				points.append(CGPoint(x:centerX, y: centerY+quarter/2))
				points.append(nil)
				points.append(nil)
				points.append(CGPoint(x:centerX, y: centerY+quarter*3/4))
				points.append(CGPoint(x:centerX, y: centerY+quarter*3/4))
			case 2:
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
			case 3:
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
				points.append(nil)
			case 4:
				centerY += quarter/2
				points.append(CGPoint(x:quarter+quarter/2, y : centerY+quarter*3/4))
				points.append(CGPoint(x:3*quarter-quarter/2, y : centerY+quarter*3/4))
				points.append(CGPoint(x:3*quarter, y : centerY+quarter/2))
				points.append(CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8))
				points.append(CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8))
				points.append(CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8))
				points.append(CGPoint(x:centerX-quarter/2, y : centerY+quarter*6/8))
				points.append(CGPoint(x:quarter, y : centerY+quarter/2))
			case 5:
				centerY += quarter/2
				points.append(nil)
				points.append(nil)
				points.append(CGPoint(x:3*quarter, y : centerY+quarter/2))
				points.append(CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8))
				points.append(CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8))
				points.append(CGPoint(x:centerX+quarter/2, y : centerY+quarter*6/8))
				points.append(CGPoint(x:centerX-quarter/2, y : centerY+quarter*6/8))
				points.append(CGPoint(x:quarter, y : centerY+quarter/2))
			default: break
		}
		return points
	}
	
	func getImage(rect: CGRect, mood: Int) -> UIImage {
		newFace(rect: rect)
		if mood > 0 {
			let mouthPath = UIBezierPath()
			let points = getPoints(rect: rect,mood: mood)
			let controlPoints = getControlPoints(rect: rect, mood: mood)
			mouthPath.move(to: points[0])
			let butfirst = points.dropFirst()
			for (i,p) in butfirst.enumerated() {
				let cp1 = controlPoints[i*2] ?? p
				let cp2 = controlPoints[i*2+1] ?? p
				mouthPath.addCurve(to: p, controlPoint1: cp1, controlPoint2: cp2)
			}
			//close
			let cp1 = controlPoints[controlPoints.count-2] ?? points[0]
			let cp2 = controlPoints[controlPoints.count-1] ?? points[0]
			mouthPath.addCurve(to: points[0], controlPoint1: cp1, controlPoint2: cp2)
			mouthPath.fill()
		}
		
		let image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
}
