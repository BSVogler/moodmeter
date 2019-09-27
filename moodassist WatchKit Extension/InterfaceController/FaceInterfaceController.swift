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
    
    // MARK: Stored Instance Properties
	let face = Measurement()
	@IBInspectable public var isYesterday: Bool = false {
		didSet {
			refreshDisplay()
		}
	}
	
	// MARK: Outlets
	@IBOutlet weak var dateLabel: WKInterfaceLabel!
	@IBOutlet weak var scenekitscene: WKInterfaceSCNScene?
	@IBOutlet weak var moodLabel: WKInterfaceLabel!
	@IBOutlet weak var background: WKInterfaceGroup!
	
    // MARK: Overridden/ Lifecycle Methods
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //connect the watchkit scene with the scene outlet
        if let interfacescene = scenekitscene,
            interfacescene.scene == nil {
            interfacescene.scene = FaceScene().scene
        }
        refreshDisplay()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
	// MARK: IBActions
	@IBAction func swipeUp(_ sender: Any) {
		// mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 4
			// face.moodChanged() this is not needed anymore, as mood is directly changed in Measurement instance
		} else if face.mood < MoodConstants.moodToText.count-1 {
			face.mood += 1
			// face.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func swipeDown(_ sender: Any) {
		//mood 0 is only internal special case
		if face.mood == 0 {
			face.mood = 2
			// face.moodChanged()
		} else if face.mood > 1 {
			face.mood -= 1
			// face.moodChanged()
		} else {
			return
		}
		refreshDisplay()
	}
	
	@IBAction func tapped(_ sender: Any) {
		if face.mood == 0 {
			face.mood = 3
			// face.moodChanged()
			refreshDisplay()
		}
	}

    // MARK: Private Instance Methods
	private func refreshDisplay(){
		moodLabel.setText(face.getSmiley())
		background.setBackgroundColor(face.getColor())
//		let filter = scenekitscene.scene?.rootNode.childNodes.filter({ $0.name == "head" }).first
//		let material = SCNMaterial.()
//		material.diffuse.contents = NSColor()
//		filter?.geometry?.replaceMaterial(at: 0, with: material)
	}
}
