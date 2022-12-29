# WLHelpers

[![Version](https://img.shields.io/cocoapods/v/WLHelpers.svg?style=flat)](http://cocoapods.org/pods/WLHelpers)
[![License](https://img.shields.io/cocoapods/l/WLHelpers.svg?style=flat)](http://cocoapods.org/pods/WLHelpers)

## Overview

WLHelpers's goal is to patch holes in native Cocoa API, to add convenience to most cumbersome of tasks. This library contains seven different helpers:

- WLUtilityHelper - multitude of utility and formatting methods, intended as a massive time-saver, shortening multi-line tasks into one call. Time and data formatting, string manipulation, application navigation, random generation, and many other frequently used tools at your disposal.

- WLKeychainHelper - a better formated KeychainWrapper from Apple's Keychain Services Programming Guide with the ability to add and retirieve basic items from the Keychain.

- WLVisualHelper - helper for all things visual, which performs tasks of CoreGraphics, Quartz and UIKit, so you don't have to.

- WLImageHelper - this tool will help you decouple image-loading from your controllers, with fallbacks and spinners and whatnot. Now you can load profile pictures of your users in one method call, even if your users have profile pictures from Facebook, VK, Twitter, and your own backend.

- WLLogHelper - convenience logging, which includes visual cues and automatically reports from which controller and method the log is called, greatly improving transparency of logs, so they are easy to read and navigate.

- WLLocationHelper - helper built around CoreLocation, which will spare you the task of doing trivial location-related tasks from scratch.

- WLCoreDataHelper - simple CoreData manager, that removes the need to specificly create CoreData project each time you want to use the framework, and makes it possible to add CoreData support on the fly.

- WLAlertHelper - the most robust helper, providing centralized control and structure to alert messages. WLAlertHelper uses UIAlertController in a way intended by Apple, while providing compact and transparent methods that are easy to use, as well as framework for managing your own alert messages in an elegant way.

## Installation

WLHelpers is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "WLHelpers"
```

To generate an empty Podfile, navigate to your project folder and execute the following command:

```shell
$ pod init
```

If you do not have CocoaPods installed, run installation command first:

```shell
$ sudo gem install cocoapods
```

If you do not want to use CocoaPods, you can simply checkout the sample project.

## Requirements

- iOS9 and higher

## Author

Leetmorry, developer@wonderslab.com

## License

WLHelpers is available under the MIT license. See the LICENSE file for more info.
