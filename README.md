# TouchMe

[![CI Status](https://img.shields.io/travis/isapozhnik/TouchMe.svg?style=flat)](https://travis-ci.org/isapozhnik/TouchMe)
[![Version](https://img.shields.io/cocoapods/v/TouchMe.svg?style=flat)](https://cocoapods.org/pods/TouchMe)
[![License](https://img.shields.io/cocoapods/l/TouchMe.svg?style=flat)](https://cocoapods.org/pods/TouchMe)
[![Platform](https://img.shields.io/cocoapods/p/TouchMe.svg?style=flat)](https://cocoapods.org/pods/TouchMe)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TouchMe is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TouchMe'
```

## FAQ
1. *Q*: Ok, I just wand to know what type of biometric authentication Is available on my device. What can you offer?

   *A: YES, for this you will need to work with `BiometricAuthenticaticationProvider`.*

Example: 
```swift
let authProvider = BiometricAuthenticaticationProvider()
print("Available biometric type is \(authProvider.availableBiometricType)")
```


## Author

isapozhnik, ivan.sapozhnik@sixt.com

## License

TouchMe is available under the MIT license. See the LICENSE file for more info.


