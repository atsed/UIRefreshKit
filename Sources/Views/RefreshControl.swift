//
//  RefreshControl.swift
//  UIRefreshKit
//
//  Created by Egor Korotkii on 7/6/24.
//

import UIKit

public final class RefreshControl: BaseRefreshControl {

    public enum Size {
        case small
        case medium

        var value: CGSize {
            switch self {
            case .small:
                return CGSize(width: 22, height: 22)
            case .medium:
                return CGSize(width: 24, height: 24)
            }
        }
    }

    // MARK: - Properties

    private let size: CGSize
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let isHapticEnabled: Bool

    // MARK: - Init

    public init(size: Size = .medium, isHapticEnabled: Bool = true) {
        self.size = size.value
        self.isHapticEnabled = isHapticEnabled
        super.init(frame: CGRect(origin: .zero, size: size.value))
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        layer.cornerRadius = size.height / 2
        backgroundColor = .clear

        setupProgressLayer()
    }

    private func setupProgressLayer() {
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: (size.height - Constants.lineWidth) / 2,
                                        startAngle: Constants.startAngle,
                                        endAngle: Constants.endAngle,
                                        clockwise: true)

        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = Constants.lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = .zero

        gradientLayer.frame = frame
        gradientLayer.colors = Constants.gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = progressLayer

        layer.addSublayer(gradientLayer)
    }

    // MARK: - Overriden Flow

    public override func setProgress(to newProgress: CGFloat) {
        layer.isHidden = newProgress <= 0.1

        guard !isRefreshing else {
            return
        }

        let animationType = Constants.AnimationType.strokeEnd
        progressLayer.removeAnimation(forKey: animationType.key)

        let animation = CABasicAnimation(keyPath: animationType.keyPath)
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress

        progressLayer.strokeEnd = newProgress

        progressLayer.add(animation, forKey: animationType.key)
    }

    public override func startRefreshing() {
        setProgress(to: 1)
        isRefreshing = true
        startHaptic()
        startScaleRotateAnimations()
    }

    public override func endRefreshing() {
        layer.isHidden = true
        isRefreshing = false
        layer.removeAllAnimations()
    }

    public override func resume() {
        if isRefreshing {
            startScaleRotateAnimations()
        } else {
            setProgress(to: .zero)
        }
    }

    // MARK: - Private Flow

    private func startScaleRotateAnimations() {
        let rotationAnimationType = Constants.AnimationType.rotation
        layer.removeAnimation(forKey: rotationAnimationType.key)

        let scaleAnimationType = Constants.AnimationType.scale
        layer.removeAnimation(forKey: scaleAnimationType.key)

        let slowSpinAnimation = animation(type: rotationAnimationType,
                                          from: .zero,
                                          to: CGFloat.pi * 2 * Constants.Animation.slowSpinsCount,
                                          duration: Constants.Animation.spinsDuration)

        let fastSpinAnimation = animation(type: rotationAnimationType,
                                          from: .zero,
                                          to: CGFloat.pi * 2 * (Constants.Animation.fastSpinsCount + Constants.Animation.slowSpinsCount),
                                          duration: Constants.Animation.spinsDuration)

        let scaleUpAnimation = animation(type: scaleAnimationType,
                                          from: Constants.Animation.scaleLowerBound,
                                          to: Constants.Animation.scaleUpperBound,
                                          duration: Constants.Animation.scaleDuration)

        let scaleDownAnimation = animation(type: scaleAnimationType,
                                          from: Constants.Animation.scaleUpperBound,
                                          to: Constants.Animation.scaleLowerBound,
                                          duration: Constants.Animation.scaleDuration)

        let spinAnimations = CAAnimationGroup(from: [slowSpinAnimation, fastSpinAnimation])
        spinAnimations.repeatCount = .infinity

        let scaleAnimations = CAAnimationGroup(from: [scaleUpAnimation, scaleDownAnimation])
        scaleAnimations.repeatCount = .infinity

        layer.add(spinAnimations, forKey: rotationAnimationType.key)
        layer.add(scaleAnimations, forKey: scaleAnimationType.key)
    }

    private func animation(type: Constants.AnimationType,
                           from fromValue: CGFloat,
                           to toValue: CGFloat,
                           duration: CFTimeInterval) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: type.keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration

        switch type {
        case .rotation:
            animation.isCumulative = true
        case .scale:
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        default:
            break
        }

        return animation
    }

    private func startHaptic() {
        guard isHapticEnabled else {
            return
        }

        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
    }

    // MARK: - Constants

    private struct Constants {
        static let gradientColors = [UIColor.white.cgColor,
                                     UIColor.darkGray.cgColor]

        static let lineWidth: CGFloat = 3

        static let startAngle: CGFloat = CGFloat(-0.5 * .pi)
        static let endAngle: CGFloat = CGFloat(1.5 * .pi)

        struct Animation {
            static let scaleUpperBound: CGFloat = 1
            static let scaleLowerBound: CGFloat = 0.8
            static let scaleDuration: CFTimeInterval = 0.8

            static let slowSpinsCount: CGFloat = 2
            static let fastSpinsCount: CGFloat = 2
            static let spinsDuration: CFTimeInterval = 0.8
        }

        enum AnimationType: String {
            case strokeEnd
            case rotation
            case scale

            var key: String {
                return "\(rawValue)Animation"
            }

            var keyPath: String {
                switch self {
                case .strokeEnd:
                    return "strokeEnd"
                case .rotation:
                    return "transform.rotation"
                case .scale:
                    return "transform.scale"
                }
            }
        }
    }
}

private extension CAAnimationGroup {

    convenience init(from sequence: [CABasicAnimation]) {
        self.init()

        let animations = chain(of: sequence)
        self.duration = animations.reduce(0) { $0 + $1.duration }
        self.animations = animations
    }

    func chain(of animations: [CABasicAnimation]) -> [CABasicAnimation] {
        for i in 1..<animations.count {
            chain(from: animations[i], to: animations[i - 1])
        }
        return animations
    }

    func chain(from animation: CABasicAnimation, to previousAnimation: CABasicAnimation) {
        animation.beginTime = previousAnimation.beginTime + previousAnimation.duration
        animation.fromValue = previousAnimation.toValue
    }
}
