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

	var pageData: [String] = []
	private var mood = 0
	private var moodToText: [String] = [":-(", ":-/", ":-|", ":-)", ":-D"]
	private var moodToColor: [UIColor] = [#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)]

	func getSmiley() -> String {
		return moodToText[mood]
	}
	
	func getColor() -> UIColor {
		return moodToColor[mood]
	}
	
	func increaseMood(){
		if mood < moodToText.count-1 {
			mood += 1
		}
	}
	
	func decreaseMood(){
		if mood > 0 {
			mood -= 1
		}
	}

	override init() {
	    super.init()
		// Create the data model.
		let dateFormatter = DateFormatter()
		pageData = dateFormatter.monthSymbols
	}

	func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
		// Return the data view controller for the given index.
		if (self.pageData.count == 0) || (index >= self.pageData.count) {
		    return nil
		}

		// Create a new view controller and pass suitable data.
		let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
		dataViewController.topLabel = self.pageData[index]
		return dataViewController
	}

	func indexOfViewController(_ viewController: DataViewController) -> Int {
		// Return the index of the given data view controller.
		// For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
		return pageData.firstIndex(of: viewController.topLabel) ?? NSNotFound
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
	    if index == self.pageData.count {
	        return nil
	    }
	    return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
	}

}

