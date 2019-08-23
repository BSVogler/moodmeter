//
//  ModelController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit
/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

class ModelController: NSObject, UIPageViewControllerDataSource {

	var pageTitle: [String] = []
	var dataset = [Date: Mood]()
	private var mood: Mood = 3
	private var moodToText: [String] = ["?", ":-(", ":-/", ":-|", ":-)", ":-D"]
	private var moodToColor: [UIColor] = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)]
	private var httpClient: MoodAPIjsonHttpClient?
	public private(set) var deviceHash: String?

	func getSmiley() -> String {
		return moodToText[mood]
	}
	
	func getColor() -> UIColor {
		return moodToColor[mood]
	}
	
	func increaseMood(){
		if mood < moodToText.count-1 {
			mood += 1
			dataset[Date()] = mood
			httpClient?.postMeasurement(measurements: [Measurement(day: Date(), mood: mood)])
		}
	}
	
	func decreaseMood(){
		if mood > 1 {
			mood -= 1
			dataset[Date()] = mood
			httpClient?.postMeasurement(measurements: [Measurement(day: Date(), mood: mood)])
		}
	}

	override init() {
		// Create the data model.
		// todo load dataset from json save file
		let dateFormatter = DateFormatter()
		pageTitle = [dateFormatter.string(from: Date())] //start with a single day
		super.init()
		
		generateSharingURL()
		httpClient = MoodAPIjsonHttpClient(model: self)
	}
	
	final func generateSharingURL(){
		//the hash does not have to be secure, just the seed, so use secure seed directly
		var bytes = [UInt8](repeating: 0, count: 40)
		let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

		if status == errSecSuccess { // Always test the status.
			let letters: [Character] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"]
			let toURL: String = String(bytes.map{ byte in letters[Int(byte % UInt8(letters.count))] })
			deviceHash = toURL
		}
	}

	func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
		// Return the data view controller for the given index.
		if (self.pageTitle.count == 0) || (index >= self.pageTitle.count) {
		    return nil
		}

		// Create a new view controller and pass suitable data.
		let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
		dataViewController.topLabel = self.pageTitle[index]
		return dataViewController
	}

	func indexOfViewController(_ viewController: DataViewController) -> Int {
		// Return the index of the given data view controller.
		// For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
		return pageTitle.firstIndex(of: viewController.topLabel) ?? NSNotFound
	}

	// MARK: - Page View Controller Data Source

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
	    var index = self.indexOfViewController(viewController as! DataViewController)
	    if (index == 0) || (index == NSNotFound) {
	        return nil
	    }
	    
	    index -= 1
	    return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
	    var index = self.indexOfViewController(viewController as! DataViewController)
	    if index == NSNotFound {
	        return nil
	    }
	    
	    index += 1
	    if index == self.pageTitle.count {
	        return nil
	    }
	    return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
	}

}

