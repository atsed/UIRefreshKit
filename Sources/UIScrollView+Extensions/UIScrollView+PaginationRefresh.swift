//
//  UIScrollView+PaginationRefresh.swift
//  UIRefreshKit
//
//  Created by Egor Korotkii on 7/6/24.
//

import UIKit

public extension UIScrollView {

    private enum PaginationRefreshState: Int {
        case idle = 1
        case pulling
        case refreshing
    }

    // MARK: - Public Properties

    @objc
    var paginationRefresh: BaseRefreshControl? {
        get {
            withUnsafePointer(to: &AssociatedKeys.paginationRefreshKey) {
                objc_getAssociatedObject(self, $0) as? BaseRefreshControl
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.paginationRefreshKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
            setPaginationRefresh()
        }
    }

    @objc
    var paginationRefreshAction: (() -> Void)? {
        get {
            withUnsafePointer(to: &AssociatedKeys.paginationRefreshActionKey) {
                objc_getAssociatedObject(self, $0) as? (() -> Void)? ?? nil
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.paginationRefreshActionKey) {
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
    var isPaginationRefreshing: Bool {
        return paginationRefreshState == .refreshing
    }

    // MARK: - Private Properties

    private var paginationRefreshState: PaginationRefreshState? {
        get {
            withUnsafePointer(to: &AssociatedKeys.paginationRefreshStateKey) {
                objc_getAssociatedObject(self, $0) as? PaginationRefreshState
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.paginationRefreshStateKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

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

    private var contentSizeObserver: NSKeyValueObservation? {
        get {
            withUnsafePointer(to: &AssociatedKeys.contentSizeObserverKey) {
                objc_getAssociatedObject(self, $0) as? NSKeyValueObservation
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.contentSizeObserverKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    private var basicContentInsetBottom: CGFloat {
        get {
            withUnsafePointer(to: &AssociatedKeys.basicContentInsetBottomKey) {
                objc_getAssociatedObject(self, $0) as? CGFloat ?? .zero
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.basicContentInsetBottomKey) {
                objc_setAssociatedObject(
                    self,
                    $0,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    private var oldContentSizeHeight: CGFloat {
        get {
            withUnsafePointer(to: &AssociatedKeys.oldContentSizeHeightKey) {
                objc_getAssociatedObject(self, $0) as? CGFloat ?? .zero
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.oldContentSizeHeightKey) {
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
    func disablePaginationRefresh() {
        paginationRefreshState = .idle
        updateState()
    }

    @objc
    func reloadPaginationRefresh() {
        guard paginationRefreshState != .pulling else {
            return
        }

        paginationRefreshState = .pulling
        updateState()
    }

    // MARK: - Private Methods

    @objc
    private func setPaginationRefresh() {
        guard let paginationRefresh else {
            return
        }

        paginationRefresh.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        addSubview(paginationRefresh)

        basicContentInsetBottom = contentInset.bottom

        contentOffsetObserver = observe(\.contentOffset,
                                         options: .new,
                                         changeHandler: { [weak self] scrollView, changes in
            guard let newContentOffsetY = changes.newValue?.y else {
                return
            }

            let isRefreshLineCrossed = newContentOffsetY >= (scrollView.contentSize.height -
                                                             scrollView.bounds.height -
                                                             scrollView.safeAreaInsets.bottom)

            if isRefreshLineCrossed &&
                self?.paginationRefreshState != .refreshing &&
                self?.paginationRefreshState != .idle &&
                scrollView.contentSize.height >= scrollView.bounds.height &&
                scrollView.bounds.height > .zero {
                self?.oldContentSizeHeight = scrollView.contentSize.height
                self?.paginationRefreshState = .refreshing
                self?.updateState()
                self?.paginationRefreshAction?()
            }
        })

        contentInsetObserver = observe(\.contentInset,
                                        options: .new,
                                        changeHandler: { [weak self] _, changes in
           guard let newContentInsetBottom = changes.newValue?.bottom else {
               return
           }

           self?.contentInsetDidChanged(with: newContentInsetBottom)
       })

        contentSizeObserver = observe(\.contentSize,
                                       options: .new,
                                       changeHandler: { [weak self] _, changes in
            guard
                let newContentSizeHeight = changes.newValue?.height,
                self?.isPaginationRefreshing ?? false
            else {
                return
            }

            if newContentSizeHeight != self?.oldContentSizeHeight ?? .zero {
                self?.oldContentSizeHeight = newContentSizeHeight
                self?.paginationRefreshState = .pulling
                self?.updateState()
            }
        })
    }

    private func contentInsetDidChanged(with newContentInsetBottom: CGFloat) {
        guard let paginationRefresh else {
            return
        }
        let paginationContainerHeight = isPaginationRefreshing ? paginationRefresh.frame.height + Constants.paginationRefreshInset * 2 : .zero

        if newContentInsetBottom != basicContentInsetBottom + paginationContainerHeight {
            basicContentInsetBottom = newContentInsetBottom
        }
    }

    private func updateState() {
        guard
            let paginationRefresh,
            let paginationRefreshState
        else {
            return
        }

        switch paginationRefreshState {
        case .pulling, .idle:
            paginationRefresh.endRefreshing()
            paginationRefresh.isHidden = true
            contentInset.bottom = basicContentInsetBottom
        case .refreshing:
            contentInset.bottom = basicContentInsetBottom + paginationRefresh.frame.height + Constants.paginationRefreshInset * 2
            paginationRefresh.frame.origin = .init(x: (frame.width - paginationRefresh.frame.width) / 2,
                                                   y: contentSize.height + Constants.paginationRefreshInset)
            paginationRefresh.startRefreshing()
            paginationRefresh.isHidden = false
        }
    }

    // MARK: - Constants

    private struct Constants {
        static let paginationRefreshInset: CGFloat = 16
    }

    // MARK: - Associated Keys

    private struct AssociatedKeys {
        static var paginationRefreshActionKey: String = "PaginationRefresh+paginationRefreshActionKey.Key"
        static var paginationRefreshKey: String = "PaginationRefresh+paginationRefreshKey.Key"
        static var paginationRefreshStateKey: String = "PaginationRefresh+paginationRefreshStateKey.Key"
        static var contentOffsetObserverKey: String = "PaginationRefresh+contentOffsetObserverKey.Key"
        static var contentInsetObserverKey: String = "RefreshControl+contentInsetObserverKey.Key"
        static var contentSizeObserverKey: String = "PaginationRefresh+contentSizeObserverKey.Key"
        static var basicContentInsetBottomKey: String = "PaginationRefresh+basicContentInsetBottomKey.Key"
        static var oldContentSizeHeightKey: String = "PaginationRefresh+oldContentSizeHeightKey.Key"
    }
}
