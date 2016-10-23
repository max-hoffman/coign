//
//  DateExtensionsTests.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/22/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import XCTest
@testable import Coign

class DateExtensionsTests: XCTestCase {

    func testDateExtensions() {
        let date = Date().shortDate
        XCTAssertNotNil(date)
        XCTAssertEqual(date.characters.count, 8)
    }
}
