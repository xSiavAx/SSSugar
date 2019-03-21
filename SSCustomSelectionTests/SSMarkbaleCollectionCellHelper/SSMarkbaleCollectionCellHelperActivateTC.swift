import XCTest
@testable import SSSugar

class SSMarkbaleCollectionCellHelperActivateTC: SSMarkbaleCollectionCellHelperBaseTC {
    func testActivate() {
        testableCellHelper.setMarking(true)
        
        checkCell(marking: true, marked: false)
    }
    
    func testActivateExplicitNonAnimated() {
        testableCellHelper.setMarking(true, animated: false)
        
        checkCell(marking: true, marked: false)
    }
    
    func testActivateAnimated() {
        testableCellHelper.setMarking(true, animated: true)
        
        checkCell(marking: true, marked: false)
    }
}
