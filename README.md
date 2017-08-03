# ObjectPool
> A small swift helper class for using an ObjectPool

[![forthebadge](http://forthebadge.com/images/badges/made-with-swift.svg)](http://forthebadge.com) [![forthebadge](http://forthebadge.com/images/badges/compatibility-betamax.svg)](http://forthebadge.com)

Compatible with:

- Swift 4
- Xcode 9
- Cocoapods 1.3


## Usage
### Init
```swift
class UIView: ObjectPoolInstance {
    required convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100)
    }
}

let objectPool = ObjectPool<SomeView>(size: 20,policy: .dynamic) { obj in
    obj.backgroundColor = UIColor.red
}

```
### Get an object from the pool:
```swift
do {
    let object = try objectPool.acquire()
    object.backgroundColor = UIColor.orange
} catch let error {
    print("Error acquiring object: \(error)")
}
```

### Done using the object:
```swift
do {
    try objectPool.release(object)
} catch let error {
    print("Error releasing object: \(error)")
}
```

### Policies

- `dynamic`: If the pool is drained, fill up the pool with +1
- `static `: The pool size is fixed. If the pool is drained, throw `Error.drained`

## Installation
### `Podfile`
```ruby
pod 'ObjectPool', :git => 'https://github.com/e-sites/ObjectPool.git'
```
