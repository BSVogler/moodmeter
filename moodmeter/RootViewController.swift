//
//  RootViewController.swift
//  moodbarometer
//
//  Created by Benedikt Stefan Vogler on 21.08.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

	var pageViewController: UIPageViewController?
	var pageControl = UIPageControl()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		// Configure the page view controller and add it as a child view controller.
		self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		self.pageViewController!.delegate = self

		let startingViewController: FaceViewController = self.modelController.viewControllerAtIndex(1, storyboard: self.storyboard!)! as! FaceViewController
		let viewControllers = [startingViewController]
		self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })

		self.pageViewController!.dataSource = self.modelController
		startingViewController.modelController = self.modelController

		self.addChild(self.pageViewController!)
		self.view.addSubview(self.pageViewController!.view)

		// Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
		var pageViewRect = self.view.bounds
		if UIDevice.current.userInterfaceIdiom == .pad {
		    pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
		}
		self.pageViewController!.view.frame = pageViewRect

		self.pageViewController!.didMove(toParent: self)
		
		configurePageControl()
	}

	var modelController: PageViewController {
		// Return the model controller object, creating it if necessary.
		// In more complex implementations, the model controller may be passed to the view controller.
		if _modelController == nil {
		    _modelController = PageViewController()
		}
		return _modelController!
	}

	var _modelController: PageViewController? = nil

	// MARK: - UIPageViewController delegate methods

	func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
		if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
		    // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewController.SpineLocation.mid' in landscape orientation sets the doubleSided property to true, so set it to false here.
		    let currentViewController = self.pageViewController!.viewControllers![0]
		    let viewControllers = [currentViewController]
		    self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

		    self.pageViewController!.isDoubleSided = false
		    return .min
		}

		// In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
		let currentViewController = self.pageViewController!.viewControllers![0] as! FaceViewController
		var viewControllers: [UIViewController]

		let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
		if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
		    let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
		    viewControllers = [currentViewController, nextViewController!]
		} else {
		    let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
		    viewControllers = [previousViewController!, currentViewController]
		}
		self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

		return .mid
	}

	func configurePageControl() {
		// The total number of pages that are available is based on how many available colors we have.
		pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
		self.pageControl.numberOfPages = modelController.pageTitles.count
		self.pageControl.currentPage = 0
		self.pageControl.tintColor = UIColor.black
		self.pageControl.pageIndicatorTintColor = UIColor.white
		self.pageControl.currentPageIndicatorTintColor = UIColor.black
		self.view.addSubview(pageControl)
	}
	// MARK: Delegate functions
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		//self.pageControl.currentPage = modelController.indexOfViewController(self) ?? 0
	}

}

