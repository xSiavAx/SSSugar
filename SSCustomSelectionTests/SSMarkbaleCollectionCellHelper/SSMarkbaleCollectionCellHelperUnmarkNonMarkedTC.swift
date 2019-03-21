import XCTest
@testable import SSSugar

class SSMarkbaleCollectionCellHelperUnmarkNonMarkedTC: SSMarkbaleCollectionCellHelperBaseTC {
    override func setUp() {
        super.setUp()
        testableCellHelper.setMarking(true)
    }
    
    func testMark() {
        testableCellHelper.setMarked(false, animated: false)
        
        checkCell(marking: true, marked: false)
    }
    
    func testMarkAnimated() {
        testableCellHelper.setMarked(false, animated: true)
        
        checkCell(marking: true, marked: false)
    }
    
    func testMarkExplicitNonAnimated() {
        testableCellHelper.setMarked(false, animated: true)
        
        checkCell(marking: true, marked: false)
    }
}
