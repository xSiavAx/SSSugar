import XCTest

class SSSugarExtensionCGRectCenterTests: XCTestCase {

    func testCenterSquare() {
        checkCenter(0, 0, 100, 100, 50, 50)
        XCTAssertEqual(CGRect(x:0, y:0, width:100, height:100).center, CGPoint(x:50, y:50))
    }
    //add tests for rect with width larger
    //add tests for rect with heioght larger
    //add tests for empty rect, moved empty rect
    //add tests for moved rects – with non zero origin
    //add tests for moved rects with negative or negative/positive origin components

    func checkCenter(_ x: CGFloat, _ y: CGFloat, _ w:CGFloat, _ h:CGFloat, _ eX:CGFloat, _ eY:CGFloat) {
        XCTAssertEqual(CGRect(x:x, y:y, width:w, height:h).center, CGPoint(x:eX, y:eY))
    }
}
