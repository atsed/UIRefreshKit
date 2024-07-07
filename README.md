# RefreshKit
[![Languages](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-red.svg)](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-red.svg)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RefreshKit.svg?style=flat)](https://img.shields.io/cocoapods/v/RefreshKit.svg?style=flat)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![License MIT](https://img.shields.io/cocoapods/l/RefreshKit.svg?style=flat)](https://raw.githubusercontent.com/atsed/RefreshKit/main/LICENSE)

`RefreshKit` is a custom library that provides customizable pull-to-refresh and automatic pagination functionality for `UICollectionView` and `UITableView`.

## Features

- Customizable Pull-to-Refresh
- Automatic Pagination
- Easy Integration

## Installation

### Swift Package Manager (SPM)

To install `RefreshKit` using SPM, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/atsed/RefreshKit.git", from: "1.0.1")
]
```

Then, in the target dependencies section, include `RefreshKit`:

```swift
.target(
    name: "YourTargetName",
    dependencies: ["RefreshKit"]
)
```

### CocoaPods

To install `RefreshKit` using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'RefreshKit'
```

Then run:

```bash
pod install
```

## Usage

### PullToRefresh

![PullToRefresh Animation](./Images/PullToRefresh.mov)

To add `PullToRefresh` to your screen, you need to set the `pullToRefresh` property for your table/collection view. You can use `RefreshControl` for this or [create your own](#creating-a-custom-refreshcontrol):

```swift
collectionView.pullToRefresh = RefreshControl()
```

The action to be performed when `PullToRefresh` is triggered is wrapped in a block:

```swift
collectionView.refreshingControlBlock = {
    // Your action
}
```

To check if the `PullToRefresh` animation is currently happening in the table/collection view, you can use the `isControlRefreshing` property:

```swift
if collectionView.isControlRefreshing {
    // Do something
}
```

To end the `PullToRefresh` animation, call the `endControlRefreshing` method:

```swift
collectionView.endControlRefreshing()
```

If you need to add a static inset from the top from which the `PullToRefresh` animation starts, use the `setRefreshControlStaticInsetTop` method:

```swift
collectionView.setRefreshControlStaticInsetTop(value: 10.0)
```

### Automatic Pagination

![Pagination Animation](./Images/Pagination.mov)

To add `Automatic Pagination` to your screen, you need to set the `paginationRefresh` property for your table/collection view. You can use `RefreshControl` for this or [create your own](#creating-a-custom-refreshcontrol):

```swift
collectionView.paginationRefresh = RefreshControl()
```

The action to be performed when `Automatic Pagination` is triggered is wrapped in a block:

```swift
collectionView.paginationRefreshingBlock = {
    // Your action
}
```

To check if the `Automatic Pagination` animation is currently happening in the table/collection view, you can use the `isPaginationRefreshing` property:

```swift
if collectionView.isPaginationRefreshing {
    // Do something
}
```

If you need to disable `Automatic Pagination`, for instance, in case of an error or when loading the last page, call the `disablePaginationRefresh` method:

```swift
collectionView.disablePaginationRefresh()
```

To resume `Automatic Pagination`, for instance, after recovering from an error, call the `reloadPaginationRefresh` method:

```swift
collectionView.reloadPaginationRefresh()
```

### Creating a Custom RefreshControl

To create a custom `RefreshControl`, you need to inherit from `BaseRefreshControl` and implement the required methods:

```swift
class CustomRefreshControl: BaseRefreshControl {
    override func setProgress(to newProgress: CGFloat) {
        // Update the appearance of your custom refresh control based on the progress
    }

    override func startRefreshing() {
        // Start the refreshing animation and the haptic
    }

    override func endRefreshing() {
        // Stop the refreshing animation
    }

    override func resume() {
        // Resume or complete the animation based on the current state
    }
}
```

## Example

Here is a basic example of how to use `RefreshKit` in a view controller:

```swift
import UIKit
import RefreshKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.pullToRefresh = RefreshControl()
        collectionView.refreshingControlBlock = { [weak self] in
            // PullToRefresh action
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self?.collectionView.endControlRefreshing()
            }
        }

        collectionView.paginationRefresh = RefreshControl(size: .small, isHapticEnabled: false)
        collectionView.paginationRefreshingBlock = { [weak self] in
            // Pagination action
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self?.collectionView.reloadPaginationRefresh()
            }
        }
    }
}
```

## License

`RefreshKit` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
