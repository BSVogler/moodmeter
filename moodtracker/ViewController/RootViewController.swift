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
	let pageControl = UIPageControl()
	
	var _modelController: PageViewController? = nil
	
	// MARK: computed property
	var modelController: PageViewController {
		// Return the model controller object, creating it if necessary.
		// In more complex implementations, the model controller may be passed to the view controller.
		if _modelController == nil {
			_modelController = PageViewController()
		}
		return _modelController!
	}
	
	// MARK: overrides
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


	
	// MARK: - UIPageViewController delegate methods
	
	func configurePageControl() {
		self.pageControl.frame = CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50)
		self.pageControl.numberOfPages = modelController.pageTitles.count
		self.pageControl.currentPage = 1
		self.pageControl.tintColor = UIColor.black
		self.pageControl.pageIndicatorTintColor = UIColor.white
		self.pageControl.currentPageIndicatorTintColor = UIColor.black
		self.pageViewController?.view.addSubview(pageControl)
	}
	// MARK: Delegate functions
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		// the current page is the number of the highlighted dot
		self.pageControl.currentPage = modelController.indexOfViewController(self.pageViewController!.viewControllers![0])
	}
}

// MARK: - Extensions
extension UIViewController {
	public func alert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Okay", style: .default) { (action) in
			alert.dismiss(animated: true, completion: nil)
		})
		self.present(alert, animated: true, completion: nil)
	}
	
	public func confirm(title: String, message: String,  deleteaction: @escaping ((UIAlertAction) -> Void) ) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { (action) in
			alert.dismiss(animated: true, completion: nil)
			deleteaction(action)
		})
		alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { (action) in
			alert.dismiss(animated: true, completion: nil)
		})
		self.present(alert, animated: true, completion: nil)
	}
}

