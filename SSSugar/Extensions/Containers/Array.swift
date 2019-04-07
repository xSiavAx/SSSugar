import Foundation

public extension Array {
    init(size: Int, buildBlock:(Int)->(Element)) {
        #warning("Fix me")
        //FIXME: Replace by new swift 5.1 array constructor
        self.init((0..<size).map(buildBlock))
    }
    
    func binarySearch(_ needle: Element, comparator: (Element, Element)->ComparisonResult) -> Int? {
        var range = 0..<count
        
        while !range.isEmpty {
            let middle = range.middle

            switch comparator(needle, self[middle]) {
            case .orderedSame:
                return middle
            case .orderedAscending:
                range = range.prefix(upTo: middle)
            case .orderedDescending:
                range = range.suffix(from: middle + 1)
            }
        }
        return nil
    }
    
    func forEach(_ body: (Element, Int) throws -> Void) rethrows {
        var idx = 0;
        
        try self.forEach { (element) in
            try body(element, idx)
            idx += 1
        }
    }
    
    //MARK: - deprecated
    /// - Warning: **Deprecated**. Use `init(size:buildBlock:)` instead.
    @available(*, deprecated, message: "Use `init(size:buildBlock:)` instead")
    static func array(size: Int, buildBlock:(Int)->(Element)) -> Array<Element> {
        return (0..<size).map(buildBlock)
    }
}

public extension Array where Element : Comparable {
    func binarySearch(_ needle: Element) -> Int? {
        return binarySearch(needle) {$0.compare($1)}
    }
}
