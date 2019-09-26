//
//  ModelController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import UIKit

// MARK: - PageViewController
/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */
class PageViewController: NSObject {
	
    // MARK: Stored Instance Properties
	var pageTitles: [String] = []

    // MARK: Initializers
	/// Create the data model.
	override init() {
		pageTitles = [NSLocalizedString("Yesterday", comment: ""),
					 NSLocalizedString("Today", comment: ""), //start with a single day
					 NSLocalizedString("Statistics", comment: ""),
					 NSLocalizedString("Share", comment: "")]
		super.init()
	}
	
    // MARK: Instance Methods
	/// Return the data view controller for the given index.
	/// - Parameter index: <#index description#>
	/// - Parameter storyboard: <#storyboard description#>
	func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> UIViewController? {
		if index >= pageTitles.count {
		    return nil
		}
		
		// Create a new view controller and pass suitable data.
		var identifier = "sbShare"
		switch index {
			case 0...1:
					identifier = "sbFace"
			case 2:
					identifier = "sbHistory"
			default:
				identifier = "sbShare"
		}
		let dataViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: identifier)
		
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
			if viewController is ShareViewController {
				return 3
			} else {
				return 2
			}
		}
	}
}

// MARK: - Extensions
// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController)
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
