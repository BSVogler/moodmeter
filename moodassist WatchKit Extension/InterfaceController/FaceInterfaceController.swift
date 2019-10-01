//
//  InterfaceController.swift
//  moodmeterwatch WatchKit Extension
//
//  Created by Benedikt Stefan Vogler on 16.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import WatchKit
import Foundation

// MARK: - Scene
class FaceScene: WKInterfaceSCNScene {
	
    // MARK: Overridden/ Lifecycle Methods
	override init() {
		super.init()
		load()
	}
	
    // MARK: Instance Methods
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

// MARK: - FaceInterfaceController
@IBDesignable
class FaceInterfaceController: WKInterfaceController {
    
    // MARK: Stored Instance Properties
	let face = Measurement()
    private var faceRenderer = FaceRenderer()
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

    // MARK: Private Instance Methods
	private func refreshDisplay(){
		background.setBackgroundColor(face.getColor())
		faceRenderer.scale = WKInterfaceDevice.current().screenScale
		faceRenderer.mood = face.mood
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

/// workaround for IB not setting values for @IBInspectable
class Yesterday: FaceInterfaceController { // What does this workaround do?
	override func willActivate(){
		super.willActivate()
		isYesterday = true
		face.day = Date.yesterday ?? Date()
	}
}
