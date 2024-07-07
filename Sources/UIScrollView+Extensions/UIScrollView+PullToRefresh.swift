//
//  UIScrollView+PullToRefresh.swift
//  PullToRefresh&Pagination
//
//  Created by Egor Korotkii on 7/6/24.
//

import UIKit

public extension UIScrollView {

    // MARK: - Public Properties

    @objc
    var pullToRefresh: BaseRefreshControl? {
        get {
            withUnsafePointer(to: &AssociatedKeys.pullToRefreshKey) {
                objc_getAssociatedObject(self, $0) as? BaseRefreshControl
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.pullToRefreshKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
            setPullToRefresh()
        }
    }

    @objc
    var refreshingControlBlock: (() -> Void)? {
        get {
            withUnsafePointer(to: &AssociatedKeys.refreshingControlBlockKey) {
                objc_getAssociatedObject(self, $0) as? (() -> Void)? ?? nil
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.refreshingControlBlockKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    @objc
    private(set) var isControlRefreshing: Bool {
        get {
            withUnsafePointer(to: &AssociatedKeys.isControlRefreshingKey) {
                objc_getAssociatedObject(self, $0) as? Bool ?? false
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.isControlRefreshingKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    // MARK: - Private Properties

    private var contentOffsetObserver: NSKeyValueObservation? {
        get {
            withUnsafePointer(to: &AssociatedKeys.contentOffsetObserverKey) {
                objc_getAssociatedObject(self, $0) as? NSKeyValueObservation
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.contentOffsetObserverKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    private var contentInsetObserver: NSKeyValueObservation? {
        get {
            withUnsafePointer(to: &AssociatedKeys.contentInsetObserverKey) {
                objc_getAssociatedObject(self, $0) as? NSKeyValueObservation
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.contentInsetObserverKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    private var basicContentInsetTop: CGFloat {
        get {
            withUnsafePointer(to: &AssociatedKeys.basicContentInsetTopKey) {
                objc_getAssociatedObject(self, $0) as? CGFloat ?? .zero
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.basicContentInsetTopKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    private var staticContentInsetTop: CGFloat {
        get {
            withUnsafePointer(to: &AssociatedKeys.staticContentInsetTopKey) {
                objc_getAssociatedObject(self, $0) as? CGFloat ?? .zero
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.staticContentInsetTopKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    private var basicAdjustedContentInsetTop: CGFloat {
        get {
            withUnsafePointer(to: &AssociatedKeys.adjustedContentInsetTopKey) {
                objc_getAssociatedObject(self, $0) as? CGFloat ?? .zero
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.adjustedContentInsetTopKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    private var isRefreshingFinished: Bool {
        get {
            withUnsafePointer(to: &AssociatedKeys.isRefreshingFinishedKey) {
                objc_getAssociatedObject(self, $0) as? Bool ?? true
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.isRefreshingFinishedKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    // MARK: - Public Methods

    @objc
    func endControlRefreshing() {
        guard isControlRefreshing else {
            return
        }

        reloadPaginationRefresh()
        isControlRefreshing = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.contentInset.top = (self?.basicContentInsetTop ?? .zero)
        }
    }

    @objc
    func setPullToRefreshStaticInsetTop(value: CGFloat) {
        staticContentInsetTop = value
    }

    // MARK: - Private Methods

    private func setPullToRefresh() {
        guard let pullToRefresh else {
            return
        }

        pullToRefresh.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        addSubview(pullToRefresh)

        alwaysBounceVertical = true
        basicContentInsetTop = contentInset.top

        contentOffsetObserver = observe(\.contentOffset,
                                         options: .new,
                                         changeHandler: { [weak self] _, changes in
            guard let newContentOffsetY = changes.newValue?.y else {
                return
            }

            self?.contentOffsetDidChanged(with: newContentOffsetY)
        })

        contentInsetObserver = observe(\.contentInset,
                                        options: [.old, .new],
                                        changeHandler: { [weak self] _, changes in
            guard
                let newContentInsetTop = changes.newValue?.top,
                newContentInsetTop != changes.oldValue?.top
            else {
                return
            }

            self?.contentInsetDidChanged(with: newContentInsetTop)
        })
    }

    private func contentOffsetDidChanged(with newContentOffsetY: CGFloat) {
        guard let pullToRefresh else {
            return
        }
        updateAdjustedContentInset()

        let triggerOffset = newContentOffsetY + basicAdjustedContentInsetTop + basicContentInsetTop

        if triggerOffset < -1 {
            let progressValue = -triggerOffset / (frame.height / 6)
            pullToRefresh.setProgress(to: progressValue)

            if progressValue >= 1, !isControlRefreshing, isRefreshingFinished {
                isControlRefreshing = true
                isRefreshingFinished = false
                refreshingControlBlock?()
                pullToRefresh.startRefreshing()
            }

            let currentOffset = basicContentInsetTop -
                                staticContentInsetTop -
                                (pullToRefresh.frame.height +
                                Constants.refreshInset * 2)
            if triggerOffset >= currentOffset,
               isControlRefreshing,
               contentInset.top != pullToRefresh.frame.height + Constants.refreshInset * 2 {
                let newContentInsetTop = staticContentInsetTop + pullToRefresh.frame.height + Constants.refreshInset * 2
                let newContentOffset = CGPoint(x: contentOffset.x,
                                               y: newContentOffsetY)
                setContentOffset(newContentOffset, animated: false)
                contentInset.top = newContentInsetTop
            }
        } else if !isControlRefreshing, !isRefreshingFinished {
            isRefreshingFinished = true
            pullToRefresh.endRefreshing()
        }

        setPullToRefreshFrame(with: newContentOffsetY)
    }

    private func contentInsetDidChanged(with newContentInsetTop: CGFloat) {
        guard let pullToRefresh else {
            return
        }
        let refreshContainerHeight = isControlRefreshing ? pullToRefresh.frame.height + Constants.refreshInset * 2 : .zero

        if newContentInsetTop != refreshContainerHeight {
            basicContentInsetTop = newContentInsetTop - refreshContainerHeight
            updateAdjustedContentInset()
        }
    }

    private func updateAdjustedContentInset() {
        basicAdjustedContentInsetTop = adjustedContentInset.top - contentInset.top
    }

    private func setPullToRefreshFrame(with newContentOffsetY: CGFloat) {
        guard let pullToRefresh else {
            return
        }

        let newX = (frame.width - pullToRefresh.frame.width) / 2
        let newY = (newContentOffsetY +
                    basicAdjustedContentInsetTop +
                    staticContentInsetTop -
                    pullToRefresh.frame.height) / 2

        pullToRefresh.frame = CGRect(x: newX,
                                      y: newY,
                                      width: pullToRefresh.frame.width,
                                      height: pullToRefresh.frame.height)
    }

    // MARK: - Constants

    private struct Constants {
        static let refreshInset: CGFloat = 8
    }

    // MARK: - Associated Keys

    private struct AssociatedKeys {
        static var refreshingControlBlockKey: String = "PullToRefresh+refreshingControlBlockKey.Key"
        static var pullToRefreshKey: String = "PullToRefresh+pullToRefreshKey.Key"
        static var contentOffsetObserverKey: String = "PullToRefresh+contentOffsetObserverKey.Key"
        static var contentInsetObserverKey: String = "PullToRefresh+contentInsetObserverKey.Key"
        static var basicContentInsetTopKey: String = "PullToRefresh+basicContentInsetTopKey.Key"
        static var staticContentInsetTopKey: String = "PullToRefresh+staticContentInsetTopKey.Key"
        static var adjustedContentInsetTopKey: String = "PullToRefresh+adjustedContentInsetTopKey.Key"
        static var isControlRefreshingKey: String = "PullToRefresh+isControlRefreshingKey.Key"
        static var isRefreshingFinishedKey: String = "PullToRefresh+isRefreshingFinishedKey.Key"
    }
}
