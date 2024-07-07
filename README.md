### PullToRefresh and Pagination

#### PullToRefresh
![PullToRefresh Animation](./Images/PullToRefresh.mov)

To add `PullToRefresh` to your screen, you need to set the `pullToRefresh` value for your table/collection. You can use `RefreshControl` for this or [create your own](#creating-a-custom-refreshcontrol):
```swift 
collection_name.pullToRefresh = RefreshControl()
```

The action to be performed when `PullToRefresh` is triggered is wrapped in a block:
```swift 
collection_name.refreshingControlBlock = {
    'action'
}
```

To check if the `PullToRefresh` animation is currently happening in the table/collection, you can use the property:
```swift 
collection_name.isControlRefreshing
```

To end the `PullToRefresh` animation, call the method:
```swift 
collection_name.endControlRefreshing()
```

If you need to add a static inset from the top from which the `PullToRefresh` animation starts, use the method:
```swift 
collection_name.setRefreshControlStaticInsetTop(value: 10.0)
```

#### Automatic Pagination
![Pagination Animation](./Images/Pagination.mov)

To add `Automatic Pagination` to your screen, you need to set the `paginationRefresh` value for your table/collection. You can use `RefreshControl` for this or [create your own](#creating-a-custom-refreshcontrol):
```swift 
collection_name.paginationRefresh = RefreshControl()
```

The action to be performed when `Automatic Pagination` is triggered is wrapped in a block:
```swift 
collection_name.paginationRefreshingBlock = {
    'action'
}
```

To check if the `Automatic Pagination` animation is currently happening in the table/collection, you can use the property:
```swift 
collection_name.isPaginationRefreshing
```

If you need to disable `Automatic Pagination`, for instance, in case of an error or when loading the last page, call the method:
```swift 
collection_name.disablePaginationRefresh()
```

To resume `Automatic Pagination`, for instance, after recovering from an error, call the method:
```swift 
collection_name.reloadPaginationRefresh()
```

#### Creating a Custom RefreshControl

To create a custom RefreshControl, you need to inherit from `BaseRefreshControl` and implement the required methods:

```swift 
func setProgress(to newProgress: CGFloat)
```
This method is called when the user pulls the screen down to allow you to change the appearance of your Refresh Control.

```swift 
func startRefreshing()
```
This method is called when the user reaches the data-fetching point, and you need to show an animation during data retrieval.

```swift 
func endRefreshing()
```
This method is called when you need to stop the animation.

```swift 
func resume()
```
This method is called when you need to continue or complete the animation depending on the current state. For example, if the user leaves the screen and then returns, but the data has not yet been loaded.
