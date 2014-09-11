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

public class Promise<T> {
    public typealias Resolve = (T) -> Void
    public typealias Reject = (NSError) -> Void
    
    let queue: dispatch_queue_t = dispatch_get_main_queue()
    
    var status: PromiseStatus = .Pending
    
    var successCallbacks: [Resolve] = []
    var failureCallbacks: [Reject] = []
    
    var value: T?
    var error: NSError?
    
    public var isPending:   Bool { get { return status == .Pending   } }
    public var isFullfiled: Bool { get { return status == .Fulfilled } }
    public var isRejected:  Bool { get { return status == .Rejected  } }
   
    public init(queue: dispatch_queue_t? = nil) {
        if queue? != nil {
            self.queue = queue!
        }
    }
    
    public convenience init(queue: dispatch_queue_t? = nil, callback: ((Resolve, Reject) -> Void)) {
        self.init(queue: queue)
        callback(self.fulfill, self.reject)
    }
    
    public func fulfill(value: T) {
        self.value = value
        self.status = .Fulfilled
        
        dispatch_async(queue) {
            for cb in self.successCallbacks {
                cb(value)
            }
        }
        self.successCallbacks = []
    }
    
    public func reject(error: NSError) {
        self.error = error
        self.status = .Rejected
        
        dispatch_async(queue) {
            for cb in self.failureCallbacks {
                cb(error)
            }
        }
        self.failureCallbacks = []
    }
    
    public func then<U>(onFulfill: (T -> U)?, onRejected: Reject? = nil) -> Promise<U> {
        var nextPromise = Promise<U>(queue: queue)
        
        switch status {
        case .Pending where onFulfill? != nil:
            successCallbacks.append({ value in
                let transformed: U = onFulfill!(value)
                nextPromise.fulfill(transformed)
            })
            
        case .Pending where onRejected? != nil:
            failureCallbacks.append({ error in
                onRejected!(error)
                nextPromise.reject(error)
            })
            
        case .Fulfilled where onFulfill? != nil:
            let transformed: U = onFulfill!(self.value!)
            nextPromise.fulfill(transformed)
            
        case .Rejected where onRejected? != nil:
            onRejected!(self.error!)
            nextPromise.reject(self.error!)
            
        default: break
        }
        
        return nextPromise
    }
}
