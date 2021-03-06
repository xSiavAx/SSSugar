import Foundation
import XCTest
import SSSugarCore

//MARK: - protocol

public protocol SSTestComparing {
    func testSameAs(other: Self) -> Bool
}

//MARK: - Static extension

public extension SSTestComparing {
    static func testSame(_ first: Self, _ second: Self) -> Bool {
        return first.testSameAs(other: second)
    }
}

//MARK: - Default implementation for Equatable

public extension SSTestComparing where Self: Equatable {
    func testSameAs(other: Self) -> Bool {
        return self == other
    }
}

//MARK: - XCTest function

public func XCTAssertTestSame<T: SSTestComparing>(_ left: T, _ right: T) {
    XCTAssert(left.testSameAs(other: right))
}

//MARK: - Default implementations for Types

extension Int: SSTestComparing {}

extension String: SSTestComparing {}

extension Array: SSTestComparing where Element: SSTestComparing {
    public func testSameAs(other: Array<Element>) -> Bool {
        elementsEqual(other) { $0.testSameAs(other: $1) }
    }
    
    public func testContainsAs(other: Array<Element>) -> Bool {
        guard self.count == other.count else { return false }
        
        func isIncluded(el: Element) -> Bool {
            return !other.contains() { $0.testSameAs(other: el) }
        }
        return filter(isIncluded).isEmpty
    }
}

extension Dictionary: SSTestComparing where Key: Equatable, Value: SSTestComparing {
    public func testSameAs(other: Dictionary<Key, Value>) -> Bool {
        elementsEqual(other) { $0.key == $1.key && $0.value.testSameAs(other: $1.value) }
    }
}

extension Optional: SSTestComparing where Wrapped: SSTestComparing {
    public func testSameAs(other: Wrapped?) -> Bool {
        switch (self, other) {
        case (.none, .none):
            return false
        case (.some(let lVal), .some(let rVal)):
            return lVal.testSameAs(other: rVal)
        default:
            return false
        }
    }
}

extension Result: SSTestComparing where Success: SSTestComparing {
    public func testSameAs(other: Result<Success, Failure>) -> Bool {
        switch (self, other) {
        case (.success(let entity), .success(let oEntity)):
            return entity.testSameAs(other: oEntity)
        case (.failure(let error), .failure(let expError)):
            return error.reflectingEqualTo(other: expError)
        case (.success(_), .failure(_)), (.failure(_), .success(_)):
            return false
        }
    }
}
