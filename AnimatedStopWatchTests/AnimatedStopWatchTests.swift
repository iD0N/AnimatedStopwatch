//
//  AnimatedStopWatchTests.swift
//  AnimatedStopWatchTests
//
//  Created by Don on 2/2/20.
//  Copyright © 2020 Don. All rights reserved.
//

import XCTest
@testable import AnimatedStopWatch

class AnimatedStopWatchTests: XCTestCase {

	var stopwatch: AnimatedStopWatch!
    override func setUp() {
		stopwatch = AnimatedStopWatch(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
	func test_TimeInterval() {
		let dateNow = Date()
		let date = dateNow.advanced(by: 10 * 60)
		XCTAssertEqual(date.timeIntervalSince1970 - dateNow.timeIntervalSince1970, 10 * 60)
	}

	func test_LabelCount() {
		XCTAssertEqual(stopwatch.labels.count, 4, "Label count doesn't equal 4 in a min:sec template")
	}
	
	func test_ChangeNumberColor() {
		let testColor: UIColor = .blue
		stopwatch.numberColors = testColor
		XCTAssertEqual(stopwatch.labels[0].textColor, testColor, "number color doesn't apply properly")
	}
	func test_ChangeFont() {
		let testFont: UIFont = .systemFont(ofSize: 10)
		stopwatch.font = testFont
		XCTAssertEqual(stopwatch.labels[0].font, testFont, "font doesn't apply properly")
	}
	func test_endDateChange() {
		let testDate = Date().addingTimeInterval(25 * 60)
		stopwatch.endDate = testDate
		XCTAssertEqual(stopwatch.labels[0].text, "2", "date doesn't apply properly")
	}
	func test_changeStyle() {
		stopwatch.watchStyle = AnimatedStopWatchStyle.three.rawValue
		XCTAssertEqual(stopwatch.labels.count, 6, "label count doesn't equal to 6 after setting to hour:min:sec template")
	}
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
