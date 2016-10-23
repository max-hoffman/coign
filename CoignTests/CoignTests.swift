//
//  CoignTests.swift
//  CoignTests
//
//  Created by Maximilian Hoffman on 9/3/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import XCTest
@testable import Coign

class CoignTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDateExtensions() {
        let date = Date().shortDate
        XCTAssertNotNil(date)
        XCTAssertEqual(date.characters.count, 8)
    }
    
}
