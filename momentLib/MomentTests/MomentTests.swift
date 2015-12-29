//
//  MomentTests.swift
//  MomentTests
//
//  Created by Kevin Musselman on 12/28/15.
//  Copyright © 2015 Kevin Musselman. All rights reserved.
//

import XCTest

class MomentTests: XCTestCase {

    let today = NSDate()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
//        let finalTime = parseDateTimeString(("today" as NSString).UTF8String)
        let d = getDate("today")
        

        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components1 = NSCalendar.currentCalendar().components(unitFlags, fromDate: d)
        let components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: today)

        XCTAssertEqual(components1, components2, "today is right")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testTomorrow(){
        let d = getDate("tomorrow")
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components1 = NSCalendar.currentCalendar().components(unitFlags, fromDate: d)
        var components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: today)
        components2.day += 1
        
        let date = NSCalendar.currentCalendar().dateFromComponents(components2)
        components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: date!)
        
//        print("components1 & 2 = \(components1) and \(components2)")
        XCTAssertEqual(components1, components2, "tomorrow is right")
    }
    
    func testYesterday(){
        let d = getDate("yesterday")
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components1 = NSCalendar.currentCalendar().components(unitFlags, fromDate: d)
        var components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: today)
        components2.day -= 1
        
        let date = NSCalendar.currentCalendar().dateFromComponents(components2)
        components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: date!)
        
//        print("components1 & 2 = \(components1) and \(components2)")
        XCTAssertEqual(components1, components2, "tomorrow is right")
        
//        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
//        
//        let components = NSDateComponents()
//        components.year = 1987
//        components.month = 3
//        components.day = 17
//        components.hour = 14
//        components.minute = 20
//        components.second = 0
//        
//        let date = calendar?.dateFromComponents(components)
    }
    
    func testDaysAgo(){
        let d = getDate("3 days ago")
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components1 = NSCalendar.currentCalendar().components(unitFlags, fromDate: d)
        var components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: today)
        components2.day -= 3
        
        let date = NSCalendar.currentCalendar().dateFromComponents(components2)
        components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: date!)
        
//        print("components1 & 2 = \(components1) and \(components2)")
        XCTAssertEqual(components1, components2, "tomorrow is right")
    }
    
    func testDayAfterTomorrow(){
        let d = getDate("day after tomorrow")
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let components1 = NSCalendar.currentCalendar().components(unitFlags, fromDate: d)
        var components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: today)
        components2.day += 2
        
        let date = NSCalendar.currentCalendar().dateFromComponents(components2)
        components2 = NSCalendar.currentCalendar().components(unitFlags, fromDate: date!)
        
//        print("components1 & 2 = \(components1) and \(components2)")
        XCTAssertEqual(components1, components2, "day after tomorrow correct")
    }
    
    func testParsePerformance() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
            _ = self.getDate("day after tomorrow")
        }
    }

    
    func testParsePerformance2() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
            _ = self.getDate("2 years from now at 1500")
        }
    }
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//            let d = NSDate()
//            let unitFlags: NSCalendarUnit = [.Minute, .Hour, .Day, .Month, .Year]
//            let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: d)
//            components.year += 2
//            components.hour = 15
//            components.minute = 0
//            
//            _ = NSCalendar.currentCalendar().dateFromComponents(components)
//        }
//    }
    
    func getDate(str:String)->NSDate {
        let when = (str as NSString).UTF8String
        let finalTime:Double = parseDateTimeString(when)
        let d = NSDate(timeIntervalSince1970: finalTime)
        return d
    }
    
}
