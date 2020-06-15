/*
 Tests for SSGroupExecutor class
 
 [Done] init
 [Done] add
 [Done] zero tasks
 [Done] one task
 [Done] several tasks
 [Done] zero tasks background queue
 [Done] one task background queue
 [Done] several tasks background queue
 [Done] several tasks mixed queues
 [Done] zero tasks
 [Done] one task background finish
 [Done] several tasks background finish
 [Done] zero tasks background queue background finish
 [Done] one task background queue background finish
 [Done] several tasks background queue background finish
 [Done] several tasks mixed queues background finish
 */

import XCTest
@testable import SSSugar

class SSGroupExecutorTests: XCTestCase {
    let sut = SSGroupExecutor()

    func testInit() {
        XCTAssertNotNil(SSGroupExecutor())
    }
    
    func testAdd() {
        XCTAssertEqual(sut.tasks.count, 0)
        for index in 1...100 {
            sut.add(task())
            XCTAssertEqual(sut.tasks.count, index)
        }
    }
    
    func testZeroTasks() {
        let expectation = XCTestExpectation()
        
        sut.finish { expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
    }
    
    func testOneTask() {
        let expectationTask = XCTestExpectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTask))
        sut.finish { expectationFinish.fulfill() }
        wait(for: [expectationTask, expectationFinish], timeout: 1, enforceOrder: true)
    }
    
    func testSeveralTasks() {
        let expectationTasks = expectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTasks))
        sut.add(fulfillTask(expectationTasks))
        sut.add(fulfillTask(expectationTasks))
        sut.finish { expectationFinish.fulfill() }
        wait(for: [expectationTasks, expectationFinish], timeout: 1, enforceOrder: true)
    }
    
    func testZeroTasksBackgroundQueue() {
        let expectation = XCTestExpectation()
        
        sut.finish { expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
    }
    
    func testOneTaskBackgroundQueue() {
        let expectationTask = XCTestExpectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTask, in: .global()))
        sut.finish { expectationFinish.fulfill() }
        wait(for: [expectationTask, expectationFinish], timeout: 1, enforceOrder: true)
    }
    
    func testSeveralTasksBackgroundQueue() {
        let queue = DispatchQueue.global()
        let expectationTasks = expectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTasks, in: queue))
        sut.add(fulfillTask(expectationTasks, in: queue))
        sut.add(fulfillTask(expectationTasks, in: queue))
        sut.finish { expectationFinish.fulfill() }
        wait(for: [expectationTasks, expectationFinish], timeout: 1, enforceOrder: true)
    }
     
    func testSeveralTasksMixedQueues() {
        let expectationTasks = expectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTasks, in: .global()))
        sut.add(fulfillTask(expectationTasks, in: .main))
        sut.add(fulfillTask(expectationTasks, in: .global()))
        sut.finish { expectationFinish.fulfill() }
        wait(for: [expectationTasks, expectationFinish], timeout: 1, enforceOrder: true)
    }
    
    func testZeroTasksBackgroundFinish() {
        let expectation = XCTestExpectation()
        
        sut.finish(queue: .global()) { expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
    }
    
    func testOneTaskBackgroundFinish() {
        let expectationTask = XCTestExpectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTask))
        sut.finish(queue: .global()) { expectationFinish.fulfill() }
        wait(for: [expectationTask, expectationFinish], timeout: 1, enforceOrder: true)
    }
    
    func testSeveralTasksBackgroundFinish() {
        let expectationTasks = expectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTasks))
        sut.add(fulfillTask(expectationTasks))
        sut.add(fulfillTask(expectationTasks))
        sut.finish(queue: .global()) { expectationFinish.fulfill() }
        wait(for: [expectationTasks, expectationFinish], timeout: 1, enforceOrder: true)
    }
    
    func testZeroTasksBackgroundQueueBackgroundFinish() {
        let expectation = XCTestExpectation()
        
        sut.finish(queue: .global()) { expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
    }
    
    func testOneTaskBackgroundQueueBackgroundFinish() {
        let expectationTask = XCTestExpectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTask, in: .global()))
        sut.finish(queue: .global()) { expectationFinish.fulfill() }
        wait(for: [expectationTask, expectationFinish], timeout: 1, enforceOrder: true)
    }
    
    func testSeveralTasksBackgroundQueueBackgroundFinish() {
        let queue = DispatchQueue.global()
        let expectationTasks = expectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTasks, in: queue))
        sut.add(fulfillTask(expectationTasks, in: queue))
        sut.add(fulfillTask(expectationTasks, in: queue))
        sut.finish(queue: .global()) { expectationFinish.fulfill() }
        wait(for: [expectationTasks, expectationFinish], timeout: 1, enforceOrder: true)
    }
     
    func testSeveralTasksMixedQueuesBackgroundFinish() {
        let expectationTasks = expectation()
        let expectationFinish = XCTestExpectation()
        
        sut.add(fulfillTask(expectationTasks, in: .global()))
        sut.add(fulfillTask(expectationTasks, in: .main))
        sut.add(fulfillTask(expectationTasks, in: .global()))
        sut.finish(queue: .global()) { expectationFinish.fulfill() }
        wait(for: [expectationTasks, expectationFinish], timeout: 1, enforceOrder: true)
    }
    
    func expectation(withFulfillmentCount count: Int = 3) -> XCTestExpectation {
        let expectation = XCTestExpectation()

        expectation.expectedFulfillmentCount = count
        return expectation
    }
    
    func task(_ queue: DispatchQueue = .main, work: @escaping () -> Void = {}) -> SSGroupExecutor.Task {
        return { handler in
            queue.async {
                work()
                handler()
            }
        }
    }
    
    func fulfillTask(_ expectation: XCTestExpectation, in queue: DispatchQueue = .main) -> SSGroupExecutor.Task {
        return task(queue) { expectation.fulfill() }
    }
}
