import XCTest
@testable import SSSugarUIKit

class SSMarkbaleCollectionCellHelperUnmarkNonMarkedTC: XCTestCase {
    let testHelper = SSMarkbaleCollectionCellHelperTestHelper()
    var sut: SSMarkbaleCollectionCellHelper!
    
    override func setUp() {
        sut = testHelper.makeCellHelper()
        sut.setMarking(true)
    }
    
    func testMark() {
        sut.setMarked(false, animated: false)
        testHelper.checkCell(sut, marking: true, marked: false)
    }
    
    func testMarkAnimated() {
        sut.setMarked(false, animated: true)
        testHelper.checkCell(sut, marking: true, marked: false)
    }
    
    func testMarkExplicitNonAnimated() {
        sut.setMarked(false, animated: true)
        testHelper.checkCell(sut, marking: true, marked: false)
    }
}
