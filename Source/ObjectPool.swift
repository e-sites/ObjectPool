//
//  ObjectPool.swift
//  ObjectPool
//
//  Created by Bas van Kuijck on 03/08/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

import Foundation

/// Every ObjectPool Instance should inherit the `ObjectPoolInstance` protocol.
/// - Warning: It's important that 
public protocol ObjectPoolInstance: class, Equatable {
    init()
}

/// An `ObjectPool` class for (de)queueing objects
///
/// ##Init:
///
///      let objectPool = ObjectPool<SomeUIView>(size: 20,policy: .dynamic) { obj in
///          obj.backgroundColor = UIColor.red
///      }
///
/// ##Get an object from the pool:
///
///      do {
///          let object = try objectPool.acquire()
///      } catch let error {
///          print("Error acquiring object: \(error)")
///      }
///
/// ##Done using the object:
///
///      do {
///          try objectPool.release(object)
///      } catch let error {
///          print("Error releasing object: \(error)")
///      }

open class ObjectPool<Instance: ObjectPoolInstance> {

    /// `ObjectPool.Error` types
    public enum Error: Swift.Error {
        /// Error getting an object from the pool, it's drained.
        /// This typically happens for `.static` Policies
        case drained

        /// The released object is not initialized by this ObjectPool
        case notInitialized

        /// The released object hasn't been acquired yet
        case notAcquired
    }

    /// The acquire policy
    public enum Policy {
        /// If the pool is drained, fill up the pool with +1
        case dynamic

        /// If the pool is drained, throw `Error.drained`
        case `static`
    }

    /// The total available size of the pool
    public var size: Int {
        return _pool.count
    }

    /// How many objects have been acquired, aka pulled out of the pool
    public var acquireCount: Int {
        return _inPool.keys.filter { _inPool[$0] == false }.count
    }

    /// The `Policy`
    public let policy: Policy

    private let _queue = DispatchQueue(label: "com.esites.library.objectpool")
    private var _pool: [Instance] = []
    private var _inPool: [Int: Bool] = [:]

    private(set) var factory: ((Instance) -> Void)?

    public init(size: Int, policy: Policy = .static, factory: ((Instance) -> Void)? = nil) {
        self.policy = policy
        self.factory = factory

        for _ in 0..<size {
            _addNewObjectToPool()
        }
    }

    @discardableResult
    fileprivate func _addNewObjectToPool() -> Instance {
        let obj = Instance()
        factory?(obj)
        _inPool[_pool.count] = true
        _pool.append(obj)
        return obj
    }
}

extension ObjectPool {

    //
    /// Gets an instance from the `ObjectPool`
    ///
    /// - Returns: The `Instance` of the `ObjectPool`
    /// - Throws: See `ObjectPool.Error`
    public func acquire() throws -> Instance {
        var instance: Instance!
        try _queue.sync {
            instance = try self._acquire()
        }
        return instance
    }

    private func _acquire() throws -> Instance {
        func ac(_ obj: Instance) -> Instance {
            if let index = _pool.index(of: obj) {
                _inPool[index] = false
            }
            return obj
        }

        guard let instance: Instance = (_pool.filter { obj in
            guard let index = _pool.index(of: obj) else {
                return false
            }
            return _inPool[index] == true
        }).first else {
            switch policy {
            case .static:
                throw Error.drained

            case .dynamic:
                let tinstance = _addNewObjectToPool()
                return ac(tinstance)
            }
        }

        return ac(instance)
    }
}

extension ObjectPool {
    /// Puts an object back (aka release) into the `ObjectPool`
    ///
    /// - Parameters
    ///    - obj: `Instance`
    /// - Throws: See `ObjectPool.Error`
    public func release(_ obj: Instance) throws {
        try _queue.sync {
            guard let index = self._pool.index(of: obj) else {
                throw Error.notInitialized
            }

            if self._inPool[index] == true {
                throw Error.notAcquired
            }
            self._inPool[index] = true
        }
    }

    /// Drains the entire pool.
    public func drain() {
        _queue.sync {
            self._inPool.removeAll()
            self._pool.removeAll()
        }
    }
}
