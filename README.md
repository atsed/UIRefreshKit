![UIRefreshKit](https://raw.githubusercontent.com/atsed/UIRefreshKit/main/Resources/UIRefreshKitLogo.png)

[![Languages](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-red.svg)](https://img.shields.io/badge/languages-Swift%20%7C%20ObjC-red.svg)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/UIRefreshKit.svg?style=flat)](https://img.shields.io/cocoapods/v/UIRefreshKit.svg?style=flat)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![License MIT](http://img.shields.io/cocoapods/l/UIRefreshKit.svg?style=flat)](https://github.com/atsed/UIRefreshKit/blob/main/LICENSE)

`UIRefreshKit` is a custom library that provides customizable pull-to-refresh and automatic pagination functionality for `UICollectionView` and `UITableView`.

## Features

- Customizable Pull-to-Refresh
- Automatic Pagination
- Easy Integration

## Installation

### Swift Package Manager (SPM)

To install `UIRefreshKit` using SPM, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/atsed/UIRefreshKit.git", from: "2.0.0")
]
```

Then, in the target dependencies section, include `UIRefreshKit`:

```swift
.target(
    name: "YourTargetName",
    dependencies: ["UIRefreshKit"]
)
```

### CocoaPods

To install `UIRefreshKit` using CocoaPods, add the following to your `Podfile`:

```ruby
pod 'UIRefreshKit', '~> 2.0.0'
```

Then run:

```bash
pod install
```

## Usage

### PullToRefresh

[View PullToRefresh Animation](https://atsed.github.io/UIRefreshKit/PullToRefresh.html)

To add `PullToRefresh` to your screen, you need to set the `pullToRefresh` property for your table/collection view. You can use `RefreshControl` for this or [create your own](#creating-a-custom-refreshcontrol):

```swift
collectionView.pullToRefresh = RefreshControl()
```

The action to be performed when `PullToRefresh` is triggered is wrapped in a block:

```swift
collectionView.pullToRefreshAction = {
    // Your action
}
```

To check if the `PullToRefresh` animation is currently happening in the table/collection view, you can use the `isPullToRefreshing` property:

```swift
if collectionView.isPullToRefreshing {
    // Do something
}
```

To end the `PullToRefresh` animation, call the `endPullToRefresh` method:

```swift
collectionView.endPullToRefresh()
```

If you need to add a static inset from the top from which the `PullToRefresh` animation starts, use the `setPullToRefreshStaticInsetTop` method:

```swift
collectionView.setPullToRefreshStaticInsetTop(value: 10.0)
```

### Automatic Pagination

[View Pagination Animation](https://atsed.github.io/UIRefreshKit/Pagination.html)

To add `Automatic Pagination` to your screen, you need to set the `paginationRefresh` property for your table/collection view. You can use `RefreshControl` for this or [create your own](#creating-a-custom-refreshcontrol):

```swift
collectionView.paginationRefresh = RefreshControl()
```

The action to be performed when `Automatic Pagination` is triggered is wrapped in a block:

```swift
collectionView.paginationRefreshAction = {
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

Here is a basic example of how to use `UIRefreshKit` in a view controller:

```swift
import UIKit
import UIRefreshKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.pullToRefresh = RefreshControl()
        collectionView.pullToRefreshAction = { [weak self] in
            // PullToRefresh action
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self?.collectionView.endPullToRefresh()
            }
        }

        collectionView.paginationRefresh = RefreshControl(size: .small, isHapticEnabled: false)
        collectionView.paginationRefreshAction = { [weak self] in
            // Pagination action
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self?.collectionView.reloadPaginationRefresh()
            }
        }
    }
}
```

## License

`UIRefreshKit` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
