//
//  BaseRefreshControl.swift
//  PullToRefresh&Pagination
//
//  Created by Egor Korotkii on 7/7/24.
//

import UIKit

public class BaseRefreshControl: UIView {

    // MARK: - Properties

    internal var isRefreshing: Bool = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNotifications()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    public override func didMoveToWindow() {
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

    // MARK: - Public Flow

    public func setProgress(to newProgress: CGFloat) {
        fatalError("Must be overridden in the subclasses")
    }

    public func startRefreshing() {
        fatalError("Must be overridden in the subclasses")
    }

    public func endRefreshing() {
        fatalError("Must be overridden in the subclasses")
    }

    public func resume() {
        fatalError("Must be overridden in the subclasses")
    }

    // MARK: - Actions

    @objc
    private func willEnterForeground() {
        resume()
    }
}
