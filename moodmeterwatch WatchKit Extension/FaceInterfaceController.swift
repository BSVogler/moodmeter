//
//  InterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import WatchKit
import Foundation

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

class FaceInterfaceController: WKInterfaceController {
	let face = Face()
	@IBOutlet weak var scenekitscene: WKInterfaceSCNScene!
	// MARK: IBActions
	@IBAction func swipeUp(_ sender: Any) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 4
		} else if face.mood < Face.moodToText.count-1 {
			face.mood += 1
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 2
		} else if face.mood > 1 {
			face.mood -= 1
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func tapped(_ sender: Any) {
		if face.mood == 0 {
			face.mood = 3
			refreshDisplay()
		}
	}
	
	
	// MARK: Overrides
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		// Configure interface objects here.
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		//connect the watchkit scene with the scene outlet
		if scenekitscene.scene == nil {
			scenekitscene.scene = FaceScene().scene
		}
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	func refreshDisplay(){
//		let filter = scenekitscene.scene?.rootNode.childNodes.filter({ $0.name == "head" }).first
//		let material = SCNMaterial.()
//		material.diffuse.contents = NSColor()
//		filter?.geometry?.replaceMaterial(at: 0, with: material)
	}
	
}
