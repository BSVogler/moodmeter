//
//  InterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import WatchKit
import Foundation

// MARK: - Scene
class FaceScene: WKInterfaceSCNScene {
	
	override init() {
		super.init()
		load()
	}
	
	func load(){
		let options:Dictionary = [SCNSceneSource.LoadingOption.createNormalsIfAbsent : true]
		
		guard let url = Bundle.main.url(forResource: "body", withExtension: "scn") else {
			print("file not found")
			return
		}
		do {
			try self.scene = SCNScene(url: url, options: options)
		} catch {
			print(error)
		}
	}
}

//MARK: - FaceInterfaceController
@IBDesignable
class FaceInterfaceController: WKInterfaceController {
	
	// MARK: Outlets
	@IBOutlet weak var dateLabel: WKInterfaceLabel!
	@IBOutlet weak var scenekitscene: WKInterfaceSCNScene?
	@IBOutlet weak var background: WKInterfaceGroup!
	@IBOutlet weak var faceImage: WKInterfaceImage!
	
	// MARK: Stored Properties
	var measure = Measurement()
	private var faceRenderer = FaceRenderer()
	
	// MARK: IBActions
	@IBAction func swipeUp(_ sender: Any) {
		//mood 0 is only internal special case
		if measure.mood == 0 {
			measure.mood = 4
			Model.shared.addMeasurment(measurement: measure)
			measure.moodChanged()
		} else if measure.mood < Measurement.moodToText.count-1 {
			measure.mood += 1
			measure.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		//mood 0 is only internal special case
		if measure.mood == 0 {
			measure.mood = 2
			Model.shared.addMeasurment(measurement: measure)
			measure.moodChanged()
		} else if measure.mood > 1 {
			measure.mood -= 1
			measure.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func tapped(_ sender: Any) {
		if measure.mood == 0 {
			measure.mood = 3
			Model.shared.addMeasurment(measurement: measure)
			measure.moodChanged()
			refreshDisplay()
		}
	}
	
	
	// MARK: Overrides
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		// Configure interface objects here.
	}
	
	override init() {
		super.init()
		NotificationCenter.default.addObserver(self, selector: #selector(self.erased), name: Measurement.erasedNotification, object: nil)
	}
	
	@objc func erased(){
		if  let existingMeasurement = Model.shared.getMeasurement(at: measure.day) {
			measure = existingMeasurement
		} else {
			measure = Measurement(day: measure.day, mood: 0)
		}
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		//connect the watchkit scene with the scene outlet
		if let interfacescene = scenekitscene,
			interfacescene.scene == nil {
			interfacescene.scene = FaceScene().scene
		}
		if let existingMeasurement = Model.shared.getMeasurement(at: measure.day) {
			measure = existingMeasurement
		}
		refreshDisplay()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	func refreshDisplay(){
		background.setBackgroundColor(measure.getColor())
		faceRenderer.scale = WKInterfaceDevice.current().screenScale
		faceRenderer.mood = measure.mood
		faceRenderer.offsetY = -self.contentFrame.height/8
		//make it a rectangle
		let frame = CGRect(x: self.contentFrame.minX, y: self.contentFrame.minY, width: self.contentFrame.width, height: self.contentFrame.height)
		faceImage.setImage(faceRenderer.getImage(rect: frame))
//		let filter = scenekitscene.scene?.rootNode.childNodes.filter({ $0.name == "head" }).first
//		let material = SCNMaterial.()
//		material.diffuse.contents = NSColor()
//		filter?.geometry?.replaceMaterial(at: 0, with: material)
	}
}

//workaround for IB not setting values for @IBInspectable
class Yesterday: FaceInterfaceController {
	override func willActivate(){
		let date = Date.yesterday()
		if  let existingMeasurement = Model.shared.getMeasurement(at: date) {
			measure = existingMeasurement
		} else {
			measure = Measurement(day: date, mood: 0)
		}
		super.willActivate()
	}
}
