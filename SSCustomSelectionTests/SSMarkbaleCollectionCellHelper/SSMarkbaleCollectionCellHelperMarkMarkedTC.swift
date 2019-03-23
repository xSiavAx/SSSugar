import XCTest

@testable import SSSugar

class SSMarkbaleCollectionCellHelperMarkMarkedTC: SSMarkbaleCollectionCellHelperBaseTC {
    override func setUp() {
        super.setUp()
        cellHelper.setMarking(true)
        cellHelper.setMarked(true)
    }
    
    func testMark() {
        cellHelper.setMarked(true, animated: false)
        
        checkCell(marking: true, marked: true)
    }
    
    func testMarkAnimated() {
        cellHelper.setMarked(true, animated: true)
        
        checkCell(marking: true, marked: true)
    }
    
    func testMarkExplicitNonAnimated() {
        cellHelper.setMarked(true, animated: true)
        
        checkCell(marking: true, marked: true)
    }
}
