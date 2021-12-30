# LoggingSwiftyBeaver

![Swift](https://img.shields.io/badge/Swift-5.2-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)
![License](https://img.shields.io/github/license/grangej/swift-log-SwiftyBeaver)

A logging backend for [SwiftLog](https://github.com/apple/swift-log) that sends log messages to [SwiftyBeaver](https://swiftybeaver.com).

An enhancment of [LoggingSwiftyBeaver](https://github.com/ShivaHuang/swift-log-SwiftyBeaver)

- adds ability to pack metadata into json
- adds ability to understand root level metadata 

## Installation 📦

Add the LoggingSwiftyBeaver package as a dependency to your `Package.swift` file.

```swift
.package(url: "https://github.com/grangej/swift-log-SwiftyBeaver.git", from: "1.0.0")
```

Add LoggingSwiftyBeaver to your target's dependencies.

```swift
.target(
    name: "Example",
    dependencies: [
        .product(name: "LoggingSwiftyBeaver", package: "swift-log-SwiftyBeaver")
    ])
```

## Usage 📝

### 1. Let's import the logging API package:
```swift
import Logging
import LoggingSwiftyBeaver
```

### 2. Create a `logger`, the label works similarly to a `DispatchQueue` label:

```swift
let logger = Logger(label: "Example") { (label) in
    SwiftyBeaver.LogHandler(label, destinations: [
        ConsoleDestination()
    ])
}
```

Alternatively, you can use `SwiftyBeaver` only in `DEBUG` build and don't print anything in `RELEASE` build:

```swift
let logger: Logger = {
    Logger(label: "Example") { (label) in
        #if DEBUG
        return SwiftyBeaver.LogHandler(label, destinations: [
            ConsoleDestination()
        ])
        #else
        return Logging.SwiftLogNoOpLogHandler()
        #endif
    }
}()
```

Futher, you can custom format and set console output to short time, log level & message:

```swift
let logger: Logger = {
    Logger(label: "Example") { (label) in
        #if DEBUG
        let console: ConsoleDestination = {
            let destination = ConsoleDestination()

            destination.format = "$DHH:mm:ss$d $L $M"

            return destination
        }()

        return SwiftyBeaver.LogHandler(label, destinations: [
            console
        ])
        #else
        return Logging.SwiftLogNoOpLogHandler()
        #endif
    }
}()
```

### 3. We're now ready to use it:

```swift
// logging an informational message
logger.info("Hello World!")

// ouch, something went wrong
logger.error("Houston, we have a problem: \(problem)")
```

## Log Levels 💜💚💙💛❤️

It's a good habit to distinguish logs by levels. However, `SwiftLog` defines 7 levels while `SwiftyBeaver` has only 5. So an 1-to-1 mapping between `SwiftLog` and `SwiftyBeaver` is not possible. Following is a table for the mapping:

| SwiftLog   | SwiftyBeaver |
| ---------- | ------------ |
| `trace`    | `verbose`    |
| `debug`    | `debug`      |
| `info`     | `info`       |
| `notice`   | `warning`    |
| `warning`  | `warning`    |
| `error`    | `error`      |
| `critical` | `error`      |

## Origin 🗄

This program was developed by [@gramgej](https://github.com/grangej) to enhance the orginal LoggingSwiftyBeaver written by [@shivahuang](https://github.com/ShivaHuang).
