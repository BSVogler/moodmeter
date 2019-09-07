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

class PageViewController: NSObject, UIPageViewControllerDataSource {
	
	var pageTitles: [String] = []

	public var httpClient: MoodAPIjsonHttpClient?
	
	override init() {
		// Create the data model.
		// todo load dataset from json save file
		pageTitles = ["Yesterday",
					 "Today", //start with a single day
					 "Stats"]
		super.init()
		
		httpClient = MoodAPIjsonHttpClient(model: Model.shared)
	}
	
	func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> UIViewController? {
		// Return the data view controller for the given index.
		if index >= pageTitles.count {
		    return nil
		}
		
		// Create a new view controller and pass suitable data.
		let dataViewController: UIViewController = index==2 ?
			storyboard.instantiateViewController(withIdentifier: "sbHistory")
			: storyboard.instantiateViewController(withIdentifier: "sbFace")
		
		if let dataViewController = dataViewController as? FaceViewController {
			dataViewController.topLabel = self.pageTitles[index]
		}
		
		if index == 0,
		   let dataViewController = dataViewController as? FaceViewController {
			dataViewController.setToYesterday()
		}

		return dataViewController
	}

	func indexOfViewController(_ viewController: UIViewController) -> Int {
		// Return the index of the given data view controller.
		if let viewController = viewController as? FaceViewController {
			// For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
			return pageTitles.firstIndex(of: viewController.topLabel) ?? NSNotFound
		} else {
			return 2
		}
	}

	// MARK: - Page View Controller Data Source

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
	    var index = self.indexOfViewController(viewController as! FaceViewController)
	    if (index == 0) || (index == NSNotFound) {
	        return nil
	    }
	    
	    index -= 1
	    return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
	    var index = self.indexOfViewController(viewController)
	    if index == NSNotFound {
	        return nil
	    }
	    
	    index += 1
	    if index == self.pageTitles.count {
	        return nil
	    }
	    return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
	}

}

