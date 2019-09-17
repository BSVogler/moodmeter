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
	
	@IBOutlet weak var scenekitscene: WKInterfaceSCNScene!
	
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
	
}
