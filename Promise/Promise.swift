//
//  Promise.swift
//  Promise
//
//  Created by Endika Gutiérrez Salas on 16/06/14.
//  Copyright (c) 2014 Endika Gutiérrez Salas. All rights reserved.
//

import Foundation

enum PromiseStatus {
    case Pending, Fulfilled, Rejected
}

class Promise<T: AnyObject> {
    typealias Resolve = (T) -> Void
    typealias Reject = (NSError) -> Void

    let queue: dispatch_queue_t = dispatch_get_main_queue()

    var status: PromiseStatus = .Pending
    var isPending: Bool { get { return status == .Pending } }

    var successCallbacks: Resolve[] = []
    var failureCallbacks: Reject[] = []

    var value: T?
    var error: NSError?

    init() { }

    init(queue: dispatch_queue_t) {
        self.queue = queue
    }

    init(callback: (Resolve, Reject) -> Void) {
        callback(self.fulfill, self.reject)
    }

    init(queue: dispatch_queue_t?, callback: (Resolve, Reject) -> Void) {
        if queue? {
            self.queue = queue!
        }

        callback(self.fulfill, self.reject)
    }

    func fulfill(value: T) {
        self.value = value
        self.status = .Fulfilled

        for cb in self.successCallbacks {
            cb(value)
        }
    }

    func reject(error: NSError) {
        self.error = error
        self.status = .Rejected

        for cb in self.failureCallbacks {
            cb(error)
        }
    }

    func then<U>(onFulfill: (T -> U)?, onRejected: Reject?) -> Promise<U> {
        var nextPromise = Promise<U>(queue: queue)


        switch status {
        case .Pending where onFulfill?:
            successCallbacks += { value in
                let transformed: U = onFulfill!(value)
                nextPromise.fulfill(transformed)
            }

        case .Pending where onRejected?:
            failureCallbacks += { error in
                onRejected!(error)
                nextPromise.reject(error)
            }

        case .Fulfilled where onFulfill?:
            let transformed: U = onFulfill!(self.value!)
            nextPromise.fulfill(transformed)

        case .Rejected where onRejected?:
            onRejected!(self.error!)
            nextPromise.reject(self.error!)

        default: break
        }

        return nextPromise
    }
}
