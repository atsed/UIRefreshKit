//
//  BaseRefreshControl.swift
//  UIRefreshKit
//
//  Created by Egor Korotkii on 7/7/24.
//

import UIKit

open class BaseRefreshControl: UIView {

    // MARK: - Properties

    public var isRefreshing: Bool = false

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupNotifications()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        resume()
    }

    // MARK: - Setup

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    // MARK: - Open Flow

    open func setProgress(to newProgress: CGFloat) {
        fatalError("Must be overridden in the subclasses")
    }

    open func startRefreshing() {
        fatalError("Must be overridden in the subclasses")
    }

    open func endRefreshing() {
        fatalError("Must be overridden in the subclasses")
    }

    open func resume() {
        fatalError("Must be overridden in the subclasses")
    }

    // MARK: - Actions

    @objc
    private func willEnterForeground() {
        resume()
    }
}
