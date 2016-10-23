//
//  VCExtensionsTests.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/23/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import XCTest
@testable import Coign

class VCExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testContentVC() {
        
        //make sure contentVC returns self if no heirarchical structure
        let vc = UIViewController()
        let emptyContentVC = vc.contentViewController
        XCTAssertEqual(vc, emptyContentVC)
        
        //navcon's content view should be the visible vc
        let navcon = UINavigationController()
        navcon.viewControllers = [vc]
        XCTAssertEqual(navcon.contentViewController, vc)
    }
    
    func testParseJSON() {
        
//        //get some JSON data
        let vc = UIViewController()
        let path = Bundle.main.path(forResource: "unitTest", ofType: "json") 
        let dataToParse = NSData(contentsOfFile: path!)
        
        //call our parser function to make it a dictionary
        let results = vc.parseJSON(validJSONObject: dataToParse)
        
        XCTAssertNotNil(results)
        
        //extract values from dictionary
        let resultOne = results?["result one"] as! Bool
        let resultTwo = results?["result two"] as! Bool
      
//        XCTAssertEqual(resultOne, false)
//        XCTAssertEqual(resultTwo, true)

//        XCTAssertFalse(resultOne)
//        XCTAssertTrue(resultTwo)
//        XCTAssertNil(resultThree)
    }
}
