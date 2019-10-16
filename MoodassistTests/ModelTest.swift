//
//  Model.swift
//  MoodassistTests
//
//  Created by Benedikt Stefan Vogler on 16.10.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

import XCTest
@testable import Moodassist

class ModelTest: XCTestCase {
	var model: Model!
	
    override func setUp() {
		model = Model.shared
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddingSingle() {
		let old = Measurement(day: Date.yesterday(), mood: 0)
		let new = Measurement()
		//insert after
		model.addMeasurment(measurement: old)
		XCTAssertEqual(model.measurements.count, 1)
		model.addMeasurment(measurement: new)
		XCTAssertEqual(model.measurements.count, 2)
		XCTAssert(model.measurements[0] === old)
		XCTAssert(model.measurements[1] === new)
		_ = model.eraseData()
		//insert before
		XCTAssertEqual(model.measurements.count, 0)
		model.addMeasurment(measurement: new)
		model.addMeasurment(measurement: old)
		XCTAssert(model.measurements[0] === old)
		XCTAssert(model.measurements[1] === new)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
