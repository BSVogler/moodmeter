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
		_ = model.eraseData()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddingSingle() {
		let old = Measurement(day: Date.yesterday(), mood: 0)
		let new = Measurement()
		//insert after
		model.addMeasurment(old)
		XCTAssertEqual(model.measurements.count, 1)
		model.addMeasurment(new)
		XCTAssertEqual(model.measurements.count, 2)
		XCTAssert(model.measurements[0] === old)
		XCTAssert(model.measurements[1] === new)
		_ = model.eraseData()
		//insert before
		XCTAssertEqual(model.measurements.count, 0)
		model.addMeasurment(new)
		model.addMeasurment(old)
		XCTAssert(model.measurements[0] === old)
		XCTAssert(model.measurements[1] === new)
    }

	func testAddingMultiple() {
		let old = Measurement(day: Date.yesterday(), mood: 0)
		let new = Measurement()
		model.addMeasurment([old, new])
		XCTAssertEqual(model.measurements.count, 2)
		
		//insert before
		let calendar = Calendar.current
		let veryveryold = Measurement(day: calendar.date(byAdding: .day, value: -7, to: Date())!.normalized(), mood: 0)
		let veryold = Measurement(day: calendar.date(byAdding: .day, value: -3, to: Date())!.normalized(), mood: 0)
		model.addMeasurment([veryveryold, veryold])
		XCTAssert(model.measurements[0] === veryveryold)
		XCTAssert(model.measurements[1] === veryold)
		XCTAssert(model.measurements[2] === old)
		XCTAssert(model.measurements[3] === new)
		XCTAssertEqual(model.measurements.count, 4)
		_ = model.eraseData()
		XCTAssertEqual(model.measurements.count, 0)
		//insert in between
		model.addMeasurment([veryveryold, old])
		model.addMeasurment([veryold, new])
		XCTAssertEqual(model.measurements.count, 4)
		XCTAssert(model.measurements[0] === veryveryold)
		XCTAssert(model.measurements[1] === veryold)
		XCTAssert(model.measurements[2] === old)
		XCTAssert(model.measurements[3] === new)
	}
	
	func testGetting(){
		XCTAssertNil(model.getMeasurement(at: Date.yesterday()))
		let old = Measurement(day: Date.yesterday(), mood: 0)
		model.addMeasurment(old)
		XCTAssertNotNil(model.getMeasurement(at: Date.yesterday()))
	}
	
	func testSubscript(){
		XCTAssertNil(model[Date.yesterday()])
		let old = Measurement(day: Date.yesterday(), mood: 3)
		model[old.day] = old.mood
		XCTAssert(model[Date.yesterday()] == 3)
	}
	
    func testPerformance() {
        // This is an example of a performance test case.
		var newItems: [Moodassist.Measurement] = []
		let calendar = Calendar.current
		for i in 0..<1000 {
			newItems.append(Measurement(day: calendar.date(byAdding: .day, value: -2*i, to: Date())!.normalized(), mood: 0))
		}
		model.addMeasurment(newItems)
		XCTAssertEqual(model.measurements.count, 1000)
		newItems.removeAll()
		for i in 0..<1000 {
			newItems.append(Measurement(day: calendar.date(byAdding: .day, value: -1*i, to: Date())!.normalized(), mood: 0))
		}
		XCTAssertEqual(newItems.count, 1000)
        self.measure {
			model.addMeasurment(newItems)
        }
    }

}
