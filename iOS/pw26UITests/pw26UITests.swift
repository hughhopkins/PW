//
//  pw26UITests.swift
//  pw26UITests
//
//  Created by Hugh Hopkins on 04/02/2017.
//  Copyright © 2020 io.pwapp. All rights reserved.
//

import XCTest

class pw26UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHidePasswordOutputToggleChangesStateAndRestoresIt() {
        let toggle = XCUIApplication().buttons["hidePasswordOutputButton"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 2))

        let wasSelected = toggle.isSelected
        toggle.tap()
        XCTAssertEqual(toggle.isSelected, !wasSelected)

        toggle.tap()
        XCTAssertEqual(toggle.isSelected, wasSelected)
    }
    
}
