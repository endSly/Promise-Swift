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

        let p0 = Promise<String>() { resolve, reject in
            
            let delay = 0.5 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_queue_create("temp", nil)) {
                resolve("1234")
            }
        }

        let p1 = p0.then() { str -> Int  in
            assert(str == "1234")
            
            return str.toInt()!
        }
        
        let p2 = p1.then() { val -> Void in
            assert(val == 1234)
        }

        let p3 = p2.then() {
            dispatch_semaphore_signal(sema)
        }

        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
        
        assert(p0.value == "1234")
        assert(p1.value == 1234)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
