/*
 Tests for contains(_:for:) method in AutoMap
 
 [Done] contained key
 [Done] not contained key
 [Done] empty AutoMap
 */

import XCTest
@testable import SSSugarCore

class AutoMapContainsTests: XCTestCase {
    typealias Item = AutoMapTestDefaultItem
    
    let testHelper = AutoMapTestHelper()
    
    func testContainedKey() {
        let sut = AutoMap(map: testHelper.arrayMap(from: .evens))
        
        XCTAssertTrue(sut.contains(Item.evensFirstValue, for: .evens))
        XCTAssertFalse(sut.contains(Item.oddsFirstValue, for: .evens))
    }
    
    func testNotContainedKey() {
        let sut = AutoMap(map: testHelper.arrayMap(from: .evens))
        
        XCTAssertFalse(sut.contains(Item.evensFirstValue, for: .new))
        XCTAssertFalse(sut.contains(Item.oddsFirstValue, for: .new))
    }
    
    func testEmptyAutoMap() {
        let sut = AutoMap<Item, [Int]>()
        
        XCTAssertFalse(sut.contains(Item.evensFirstValue, for: .evens))
        XCTAssertFalse(sut.contains(Item.oddsFirstValue, for: .evens))
    }
}