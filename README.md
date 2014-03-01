ARTSDK
======
ArtAPI is a common library that can be included in any Art.com iOS application.

At it's core is an inteface to communicate with the Art.com server API.

It also contains view controllers that can be shared across apps. For example a login form and checkout flow. The code in Controllers is currently experimental and shouldn't be used.

Finally the library contains helper class and categories that are useful to all app.

## How To Get Started

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like AFNetworking in your projects.

If you have not installed CocoaPods, please do so with the following command:

```
$ sudo gem install cocoapods
```

#### Podfile

```ruby
platform :ios, '7.0'
pod "ARTSDK", :git => 'https://github.com/artcode/ARTSDK.git', :tag => '0.0.1'
```

For Development, you can pull in the source like:
```ruby
platform :ios, '7.0'
pod 'ARTSDK' , :path => '~/src/ARTSDK'
```
Where path points to your ARTSDK location on disk.

## Example

To run the example you must first install the Podfile.  You can do this by:

```
cd Example
pod install
```

Then open the project file: ARTSDKExample.xcworkspace



## Components
* [Share](docs/ArtAPI-Share.md)	 - A compoent to share content.

