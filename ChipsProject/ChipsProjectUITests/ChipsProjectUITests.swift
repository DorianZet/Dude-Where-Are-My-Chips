//
//  ChipsProjectUITests.swift
//  ChipsProjectUITests
//
//  Created by Mateusz Zacharski on 31/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import XCTest

class ChipsProjectUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launchArguments.append("--uitesting")
    }
    
    override func setUp() {
        super.setUp()
        app.launchArguments += ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testExitToMainMenuImmediately() throws {
        
        app.activate()
        app.buttons["PLAY"].tap()
        app.scrollViews.otherElements.buttons["START GAME"].tap()
        
        sleep(3) // wait 3 seconds for Hand State label to disappear
        
        app/*@START_MENU_TOKEN@*/.buttons["homeButton"]/*[[".buttons[\"homeicon\"]",".buttons[\"homeButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["OK"].tap()
        
        XCTAssert(app.buttons["PLAY"].exists, "Exiting to main menu failed")
    }
    
    func testCheckIfWeSeeAnAd() throws {
        
        app.activate()
        app.buttons["PLAY"].tap()
        app.scrollViews.otherElements.buttons["START GAME"].tap()
       
        sleep(3) // wait 3 seconds for Hand State label to disappear
        
        app.buttons["FOLD"].tap()
               
        app.buttons["OK"].tap()
        
        XCTAssert(app.buttons["NEW HAND"].waitForExistence(timeout: 5), "The NEW HAND button was not shown")
        
        app.buttons["NEW HAND"].tap()
        
        XCTAssert(app.staticTexts["Test mode"].exists, "The ad was not shown")
    }
    
    func testRequestReviewAlertControllerIsTrue() {
        
        app.buttons["PLAY"].tap()
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.buttons["START GAME"].tap()
       
        sleep(3) // wait 3 seconds for Hand State label to disappear

        app.buttons["RAISE"].tap()
        
        let slider = app.sliders["betSlider"]

        slider.adjust(toNormalizedSliderPosition: 1)
        
        let okButton = app.buttons["OK"]
        okButton.tap()
        
        app.buttons["ALL IN"].tap()
        
        let button = app.buttons[">"]
        button.tap()
        button.tap()
        
        let button2 = app.buttons["<"]
        button2.tap()
        button2.tap()
        okButton.tap()
        XCTAssert(elementsQuery.buttons["Not Now"].waitForExistence(timeout: 10), "Request review alert controller didn't appear. Ensure that the test launch simulates the first launch of the app.")
    }
    
    
}
