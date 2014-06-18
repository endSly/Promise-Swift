//
//  PromiseTests.swift
//  PromiseTests
//
//  Created by Endika Gutiérrez Salas on 16/06/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

import XCTest
import Foundation

class PromiseTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPromises() {

        let sema: dispatch_semaphore_t? = dispatch_semaphore_create(0)

        var result: Int? = nil

        let p0 = Promise<NSString>()

        let p1 = p0.then({ (str: NSString) -> NSNumber  in
                assert(str == "1234")
                return Int(str.intValue)
            }, onRejected: { error in

            })

        let p2 = p1.then({ (val: NSNumber) -> NSNumber in
                assert(val == 1234)
                return val
            }, onRejected: { error in

            })

        p2.then({ (val: NSNumber) -> NSNumber in
                result = Int(val)
                dispatch_semaphore_signal(sema)
                return val
            }, onRejected: { error in

            })

        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

        dispatch_after(time, dispatch_queue_create("temp2", nil)) {
            p0.fulfill("1234")
        }

        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)

        assert(result?)
        assert(result! == 1234)

        // Test after fulfill
        p2.then({ (val: NSNumber) -> NSNumber in
                result = 4321
                return val
            }, onRejected: { error in

            })

        assert(result! == 4321)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
