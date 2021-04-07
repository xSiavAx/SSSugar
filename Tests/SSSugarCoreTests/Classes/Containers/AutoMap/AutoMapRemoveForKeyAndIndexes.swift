/*
 Tests for remove(forKeyAndIndexes:) method in AutoMap

 [Done] contained keys contained
 [Done] contained keys all
 [Done] contained keys reversed contained
 [Done] not contained keys
 [Done] multiple keys
 [Done] mixed keys
 [Done] empty AutoMap
 [fatalError] not contained index
 */

import XCTest
@testable import SSSugarCore

class AutoMapRemoveForKeyAndIndexes: XCTestCase {
    typealias Item = AutoMapTestDefaultItem
    
    let testHelper = AutoMapTestHelper()

    func testContainedKeysContainedIndices() {
        var sut = AutoMap(map: testHelper.arrayMap(from: .evens, .odds))
        let keysAndIndices = AutoMap(map: Item.evens.keyAndTwoIndices)
        let result = sut.remove(forKeyAndIndexes: keysAndIndices)
        
        testHelper.assertEqual(result, Item.evens.keyAndTwoValues)
        testHelper.assertEqual(sut, testHelper.arrayMap(from: .evensWithoutTwoIndices, .odds))
    }
    
    func testContainedKeysAllIndices() {
        var sut = AutoMap(map: testHelper.arrayMap(from: .evens, .odds))
        let keyAndIndices = AutoMap(map: testHelper.arrayMap(from: .evensIndices))
        let result = sut.remove(forKeyAndIndexes: keyAndIndices)
        
        testHelper.assertEqual(result, testHelper.arrayMap(from: .evens))
        testHelper.assertEqual(sut, testHelper.arrayMap(from: .odds))
    }
    
    func testContainedKeysReversedContainedIndices() {
        var sut = AutoMap(map: testHelper.arrayMap(from: .evens, .odds))
        let keysAndIndices = AutoMap(map: Item.evens.reversedKeyAndTwoIndices)
        let result = sut.remove(forKeyAndIndexes: keysAndIndices)

        testHelper.assertEqual(result, Item.evens.keyAndTwoValues)
        testHelper.assertEqual(sut, testHelper.arrayMap(from: .evensWithoutTwoIndices, .odds))
    }
    
    
    func testNotContainedKeys() {
        let map = testHelper.arrayMap(from: .evens, .odds)
        var sut = AutoMap(map: map)
        let keysAndIndices = AutoMap(map: testHelper.arrayMap(from: .fibonacci))
        let result = sut.remove(forKeyAndIndexes: keysAndIndices)
        
        testHelper.assertEqual(result, [:])
        testHelper.assertEqual(sut, map)
    }
    
    func testMultipleKeys() {
        var sut = AutoMap(map: testHelper.arrayMap(from: .evens, .odds, .fibonacci))
        let keysAndIndices = AutoMap(map: testHelper.arrayMap(from: .evensIndices, .oddsIndices))
        let result = sut.remove(forKeyAndIndexes: keysAndIndices)
        
        testHelper.assertEqual(result, testHelper.arrayMap(from: .evens, .odds))
        testHelper.assertEqual(sut, testHelper.arrayMap(from: .fibonacci))
    }
    
    func testMixedKeys() {
        var sut = AutoMap(map: testHelper.arrayMap(from: .evens, .odds))
        let keysAndIndices = AutoMap(map: testHelper.arrayMap(from: .fibonacci, .evensIndices))
        let result = sut.remove(forKeyAndIndexes: keysAndIndices)
        
        testHelper.assertEqual(result, testHelper.arrayMap(from: .evens))
        testHelper.assertEqual(sut, testHelper.arrayMap(from: .odds))
    }
    
    func testEmptyAutoMap() {
        var sut = AutoMap<Item, [Int]>()
        let keysAndIndices = AutoMap(map: testHelper.arrayMap(from: .evensIndices))
        let resutl = sut.remove(forKeyAndIndexes: keysAndIndices)
        
        testHelper.assertEqual(resutl, [:])
        testHelper.assertEqual(sut, [:])
    }
}