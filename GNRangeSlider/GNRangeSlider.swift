//
//  GNRangeSlider.swift
//  GNRangeSlider
//
//  Created by george on 30/04/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit


// MARK: - Protocol

public protocol GNRangeSliderDelegate {
    func didBeginTracking(in slider: GNRangeSlider)
    func didEndTracking(in slider: GNRangeSlider)
    func didTrackingValuesChange(_ slider: GNRangeSlider, lowerValue: CGFloat, upperValue: CGFloat)
}

public extension GNRangeSliderDelegate {
    func didBeginTracking(in slider: GNRangeSlider) {}
    func didEndTracking(in slider: GNRangeSlider) {}
    func didTrackingValuesChange(_ slider: GNRangeSlider, lowerValue: CGFloat, upperValue: CGFloat) {}
}



public class GNRangeSlider: UIControl {
    
    public var minimumValue: CGFloat = 0 {
        didSet {
            setupFrames()
        }
    }
    
    public var maximumValue: CGFloat = 100 {
        didSet {
            setupFrames()
        }
    }
        
    public var lowerValue: CGFloat = 0 {
        didSet {
            if lowerValue < minimumValue {
                lowerValue = minimumValue
            }
            if lowerValue > upperValue {
                lowerValue = upperValue
            }

            if (!isAnimatedTrackingEnabled && _tracking == .automatic) || _tracking == .snapping {
                ///apply changes to the frame for each layer immediately, and not animated
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                lowerValueLabel.string = numberFormatter.string(from: lowerValue as NSNumber)
                leftThumb.frame = getLeftThumbFrame()
                lowerValueLabel.frame = getLowerValueLabelFrame()
                trackHighlighted.frame = getTrackHighlightedFrame()
                updateLabelFramesIfOverlapping()
                
                CATransaction.commit()
            } else {
                lowerValueLabel.string = numberFormatter.string(from: lowerValue as NSNumber)
                leftThumb.frame = getLeftThumbFrame()
                lowerValueLabel.frame = getLowerValueLabelFrame()
                trackHighlighted.frame = getTrackHighlightedFrame()
                updateLabelFramesIfOverlapping()
            }
            
        }
    }
    
    public var upperValue: CGFloat = 100 {
        didSet {
            if upperValue > maximumValue {
                upperValue = maximumValue
            }
            if upperValue < lowerValue  {
                upperValue = lowerValue
            }
            
            if (!isAnimatedTrackingEnabled && _tracking == .automatic) || _tracking == .snapping {
                ///ensures that the changes to the frame for each layer are applied immediately, and not animated
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                upperValueLabel.string = numberFormatter.string(from: upperValue as NSNumber)
                rightThumb.frame = getRightThumbFrame()
                upperValueLabel.frame = getUpperValueLabelFrame()
                trackHighlighted.frame = getTrackHighlightedFrame()
                updateLabelFramesIfOverlapping()
                
                CATransaction.commit()
            } else {
                upperValueLabel.string = numberFormatter.string(from: upperValue as NSNumber)
                rightThumb.frame = getRightThumbFrame()
                upperValueLabel.frame = getUpperValueLabelFrame()
                trackHighlighted.frame = getTrackHighlightedFrame()
                updateLabelFramesIfOverlapping()
            }
            
        }
    }
    
    public var step: CGFloat = 0 {
        didSet {
            if step < 0 {
                step = 0
            }
        }
    }
    
    public var minimumSelectedRange: CGFloat = 0 {
        didSet {
            if minimumSelectedRange < 0 {
                minimumSelectedRange = 0
            }
        }
    }
    
    public var trackColor: UIColor = UIColor.lightGray.withAlphaComponent(0.8) {
        didSet {
            track.backgroundColor = trackColor.cgColor
        }
    }
    
    public var trackHighlightedColor: UIColor = UIColor.systemBlue {
        didSet {
            trackHighlighted.backgroundColor = trackHighlightedColor.cgColor
        }
    }
    
    /// 0: square, 1: circle
    public var trackCurvature: CGFloat = 1 {
        didSet {
            guard (0...1).contains(trackCurvature) else { return }
            track.cornerRadius = (trackThickness / 2) * trackCurvature
        }
    }
    
    public var trackThickness: CGFloat = 8 {
        didSet {
            [track, trackHighlighted].forEach({
                $0.frame.size.height = trackThickness
            })
            trackCurvature = 1 * trackCurvature
        }
    }
    
    public var thumbDiameter: CGFloat = 20 {
        didSet {
            [leftThumb, rightThumb].forEach({
                $0.frame.size = CGSize(width: thumbDiameter, height: thumbDiameter)
            })
            thumbCurvature = 1 * thumbCurvature
        }
    }
    
    public var thumbDiameterMultiplier: CGFloat = 1.3
    
    public var thumbImage: UIImage? {
        didSet {
            guard var image = thumbImage else { return }
            image = image.resizedImageWithinRect(rectSize: CGSize(width: thumbDiameter, height: thumbDiameter))
            
            var frame = CGRect.zero
            frame.size = image.size
            
            [leftThumb, rightThumb].forEach { (thumb) in
                thumb.frame = frame
                thumb.contents = image.cgImage
                thumb.masksToBounds = true
            }
        }
    }
    
    public var thumbColor: UIColor = .systemRed {
        didSet {
            [leftThumb, rightThumb].forEach { (thumb) in
                thumb.backgroundColor = thumbColor.cgColor
            }
        }
    }
    
    public var thumbBorderColor: UIColor = .gray {
        didSet {
            [leftThumb, rightThumb].forEach { (thumb) in
                thumb.borderColor = thumbBorderColor.cgColor
            }
        }
    }
    
    public var thumbBorderWidth: CGFloat = 1 {
        didSet {
            guard thumbBorderWidth >= 0 else { return }
            [leftThumb, rightThumb].forEach { (thumb) in
                thumb.borderWidth = thumbBorderWidth
            }
        }
    }
    
    /// 0: square, 1: circle
    public var thumbCurvature: CGFloat = 1 {
        didSet {
            guard (0...1).contains(thumbCurvature) else { return }
            [leftThumb, rightThumb].forEach { (thumb) in
                thumb.cornerRadius = (thumbDiameter / 2) * thumbCurvature
            }
        }
    }
    
    public var textFont = UIFont.systemFont(ofSize: 12, weight: .light) {
        didSet {
            [lowerValueLabel, upperValueLabel].forEach { (label) in
                label.font = textFont
            }
        }
    }
    
    public var textColor: UIColor = .black {
        didSet {
            [lowerValueLabel, upperValueLabel].forEach { (label) in
                label.foregroundColor = textColor.cgColor
            }
        }
    }
    
    public lazy var numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f
    }()

    
    
    private let track = CALayer()
    private let trackHighlighted = CALayer()
    private let leftThumb = CALayer()
    private let rightThumb = CALayer()
    private let lowerValueLabel = CATextLayer()
    private let upperValueLabel = CATextLayer()
    
    /// threshold x values for the labels when the push each other (so they remain inside the appropriate frame)
    private var minimumLowerLabelFrameX: CGFloat = 0
    private var maximumUpperLabelFrameX: CGFloat = 0

    private enum ControlThumb { case none, left, right }
    private var controlThumb: ControlThumb = .none
    
    public enum TextPosition { case top, bottom, none }
    private var textPosition: TextPosition = .top
    
    public enum Tracking { case animatable, snapping, automatic }
    private var _tracking: Tracking = .automatic
    
    private var isAnimatedTrackingEnabled = false
    private var previousTouchLocation: CGPoint = .zero /// used when there is a step > 0
    private var previousLabelsOverlap: CGFloat = 0
        
    public var delegate: GNRangeSliderDelegate?
    
    
    
    public init(textPosition: TextPosition = .top, tracking: Tracking = .automatic) {
        self.textPosition = textPosition
        self._tracking = tracking
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard controlThumb == .none else { return }
        let maxH = (thumbDiameter * thumbDiameterMultiplier) + (textFont.pointSize * 2) + 8 /// cosmetic padding
        if frame.height < maxH {
            frame.size.height = maxH
        }
        lowerValue *= 1 /// in case the numberFormatter properties changed
        upperValue *= 1
        
        setupFrames()
        
        minimumLowerLabelFrameX = min(0, lowerValueLabel.frame.minX)
        maximumUpperLabelFrameX = max(bounds.maxX, upperValueLabel.frame.maxX)
    }
        
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        disableIOS13InteractiveDismissal()
        previousTouchLocation = touch.location(in: self)
        
        let locInset: CGFloat = -thumbDiameter
        let isTouchingLeftThumb: Bool = leftThumb.frame.insetBy(dx: locInset, dy: locInset).contains(previousTouchLocation)
        let isTouchingRightThumb: Bool = rightThumb.frame.insetBy(dx: locInset, dy: locInset).contains(previousTouchLocation)

        guard isTouchingLeftThumb || isTouchingRightThumb else { return false }
        
        let distanceFromLeftThumb = previousTouchLocation.distance(to: leftThumb.frame.center)
        let distanceFromRightThumb = previousTouchLocation.distance(to: rightThumb.frame.center)

        let isControllingLeftThumb = (distanceFromLeftThumb < distanceFromRightThumb) ||
            (upperValue == maximumValue && leftThumb.frame.midX == rightThumb.frame.midX)
        controlThumb = isControllingLeftThumb ? .left : .right

        let thumb = (controlThumb == .left) ? leftThumb : rightThumb
        animateSize(of: thumb, isTracking: true)

        delegate?.didBeginTracking(in: self)
        return true
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard controlThumb != .none else { return false }
        
        let touchLocation = touch.location(in: self)
        
        // if there is any step wait until the appropriate distance is covered
        let deltaLocation = CGFloat(touchLocation.x - previousTouchLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / track.frame.width
        if abs(deltaValue) < step {
            return true
        }
        previousTouchLocation = touchLocation
        
        // find the new value
        let thumbDistance = touchLocation.x - track.frame.minX
        let trackWidth = track.frame.width
        let percentage = thumbDistance / trackWidth
        let selectedValue = percentage * (maximumValue - minimumValue) + minimumValue
                
        switch controlThumb {
        case .left:
            let newVal = min(selectedValue, upperValue)
            if step > 0 {
                lowerValue = newVal > lowerValue ? lowerValue + step : lowerValue - step
            } else {
                lowerValue = newVal
            }
        case .right:
            let newVal = max(selectedValue, lowerValue)
            if step > 0 {
                upperValue = newVal > upperValue ? upperValue + step : upperValue - step
            } else {
                upperValue = newVal
            }
        case .none: break
        }
        
        let currentRange = upperValue - lowerValue
        isAnimatedTrackingEnabled = currentRange <= minimumSelectedRange
        
        if currentRange < minimumSelectedRange {
            switch controlThumb {
            case .left: lowerValue = upperValue - minimumSelectedRange
            case .right: upperValue = lowerValue + minimumSelectedRange
            case .none: break
            }
        }

        delegate?.didTrackingValuesChange(self, lowerValue: lowerValue, upperValue: upperValue)
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        let thumb = (controlThumb == .left) ? leftThumb : rightThumb
        animateSize(of: thumb, isTracking: false)
        controlThumb = .none
        enableIOS13InteractiveDismissal()
        delegate?.didEndTracking(in: self)
    }
    
    override public func cancelTracking(with event: UIEvent?) {
        let thumb = (controlThumb == .left) ? leftThumb : rightThumb
        animateSize(of: thumb, isTracking: false)
        controlThumb = .none
        enableIOS13InteractiveDismissal()
        delegate?.didEndTracking(in: self)
    }

    
    
    
    private func setupView() {
        layer.addSublayer(track)
        layer.addSublayer(trackHighlighted)
        layer.addSublayer(leftThumb)
        layer.addSublayer(rightThumb)
        
        if textPosition != .none {
            layer.addSublayer(lowerValueLabel)
            layer.addSublayer(upperValueLabel)
            [lowerValueLabel, upperValueLabel].forEach { (label) in
                label.font = textFont
                label.fontSize = textFont.pointSize
                label.foregroundColor = textColor.cgColor
                label.alignmentMode = .center
                label.contentsScale = UIScreen.main.scale
            }
        }
                
        track.backgroundColor = trackColor.cgColor
        track.cornerRadius = (trackThickness / 2) * trackCurvature
        
        trackHighlighted.backgroundColor = trackHighlightedColor.cgColor
        
        [leftThumb, rightThumb].forEach { (thumb) in
            thumb.backgroundColor = thumbColor.cgColor
            thumb.cornerRadius = (thumbDiameter / 2) * thumbCurvature
            thumb.borderWidth = thumbBorderWidth
            thumb.borderColor = thumbBorderColor.cgColor
        }
    }
    
    private func disableIOS13InteractiveDismissal() {
        /// in case it is a navigation controller or just a controller
        guard let vc = getTopViewController() else { return }
        vc.navigationController?.presentationController?.presentedView?.gestureRecognizers?.forEach({ $0.isEnabled = false })
        vc.presentationController?.presentedView?.gestureRecognizers?.forEach({ $0.isEnabled = false })
    }
    
    private func enableIOS13InteractiveDismissal() {
        /// in case it is a navigation controller or just a controller
        guard let vc = getTopViewController() else { return }
        vc.navigationController?.presentationController?.presentedView?.gestureRecognizers?.forEach({ $0.isEnabled = true })
        vc.presentationController?.presentedView?.gestureRecognizers?.forEach({ $0.isEnabled = true })
    }
    
    private func setupFrames() {
        track.frame = getTrackFrame()
        leftThumb.frame = getLeftThumbFrame()
        rightThumb.frame = getRightThumbFrame()
        trackHighlighted.frame = getTrackHighlightedFrame()
        
        lowerValueLabel.frame = getLowerValueLabelFrame()
        upperValueLabel.frame = getUpperValueLabelFrame()
    }
    
    private func getTrackFrame() -> CGRect {
        return CGRect(x: thumbDiameter / 2, y: (frame.height / 2) - trackThickness / 2, width: frame.width - thumbDiameter, height: trackThickness)
    }

    private func getTrackHighlightedFrame() -> CGRect {
        return CGRect(x: leftThumb.frame.midX, y: track.frame.origin.y, width: rightThumb.frame.midX - leftThumb.frame.midX, height: trackThickness)
    }
    
    private func getLeftThumbFrame() -> CGRect {
        let d = isTracking ? thumbDiameter * thumbDiameterMultiplier : thumbDiameter
        let yOffset = d / 2
        let totalWidth = track.frame.width
        let xPercentage = (lowerValue - minimumValue) / (maximumValue - minimumValue)
        return CGRect(x: xPercentage * totalWidth, y: track.frame.midY - yOffset, width: d, height: d)
    }
    
    private func getRightThumbFrame() -> CGRect {
        let d = isTracking ? thumbDiameter * thumbDiameterMultiplier : thumbDiameter
        let yOffset = d / 2
        let totalWidth = track.frame.width
        let xPercentage = (upperValue - minimumValue) / (maximumValue - minimumValue)
        return CGRect(x: xPercentage * totalWidth, y: track.frame.midY - yOffset, width: d, height: d)
    }
        
    private func getLowerValueLabelFrame(_ overlappingOffset: CGFloat = 0) -> CGRect {
        var size = CGSize(width: leftThumb.frame.width, height: textFont.pointSize)
        if let fitSize = (lowerValueLabel.string as? NSString)?.size(withAttributes: [NSAttributedString.Key.font : textFont]) {
            size = fitSize
        }
        
        var yOffset: CGFloat = 4
        switch textPosition {
        case .top: yOffset = -yOffset - size.height
        case .bottom: yOffset = yOffset + leftThumb.frame.height
        case .none: break
        }
        
        var rect = CGRect(origin: CGPoint(x: leftThumb.frame.midX - size.width / 2, y: leftThumb.frame.minY + yOffset), size: size)
        
        if overlappingOffset != 0 {
            rect.size.width += overlappingOffset
            rect.origin.x -= overlappingOffset / 2
            lowerValueLabel.alignmentMode = .left
        } else {
            lowerValueLabel.alignmentMode = .center
        }
        
//        if minimumLowerLabelFrameX != 0 {
            rect.origin.x = max(rect.origin.x, minimumLowerLabelFrameX)
//        }
        
        return rect
    }
    
    private func getUpperValueLabelFrame(_ overlappingOffset: CGFloat = 0) -> CGRect {
        var size = CGSize(width: rightThumb.frame.width, height: textFont.pointSize)
        if let fitSize = (upperValueLabel.string as? NSString)?.size(withAttributes: [NSAttributedString.Key.font : textFont]) {
            size = fitSize
        }

        var yOffset: CGFloat = 4
        switch textPosition {
        case .top: yOffset = -yOffset - size.height
        case .bottom: yOffset = yOffset + rightThumb.frame.height
        case .none: break
        }
        
        var rect = CGRect(origin: CGPoint(x: rightThumb.frame.midX - size.width / 2, y: rightThumb.frame.minY + yOffset), size: size)

        if overlappingOffset != 0 {
            rect.size.width += overlappingOffset
            upperValueLabel.alignmentMode = .right
        } else {
            upperValueLabel.alignmentMode = .center
        }
        
        rect.origin.x = min(rect.minX, maximumUpperLabelFrameX - rect.width)

        return rect
    }
    
    private func updateLabelFramesIfOverlapping() {
        previousLabelsOverlap = lowerValueLabel.frame.maxX - upperValueLabel.frame.minX + 4 /// added cosmetic offset

        switch controlThumb {
        case .left:
            if previousLabelsOverlap > 0 { /// the two labels intersect
                lowerValueLabel.frame.size.width += previousLabelsOverlap / 2
                lowerValueLabel.frame.origin.x -= previousLabelsOverlap / 2
                lowerValueLabel.frame.origin.x = max(lowerValueLabel.frame.origin.x, minimumLowerLabelFrameX)
                lowerValueLabel.alignmentMode = .left
                /// recalculate overlap in case lowerValueLabel is at the minimum boundary
                let newOverlap = lowerValueLabel.frame.maxX - upperValueLabel.frame.minX + 4
                let diff = abs(newOverlap / 2 - previousLabelsOverlap / 2)
                upperValueLabel.frame = getUpperValueLabelFrame(newOverlap / 2 + diff)
            } else {
                lowerValueLabel.alignmentMode = .center
                upperValueLabel.frame = getUpperValueLabelFrame(0)
            }
            
        case .right:
            if previousLabelsOverlap > 0 { /// the two labels intersect
                upperValueLabel.frame.size.width += previousLabelsOverlap / 2
                upperValueLabel.alignmentMode = .right
                upperValueLabel.frame.origin.x = min(upperValueLabel.frame.minX, maximumUpperLabelFrameX - upperValueLabel.frame.width)
                /// recalculate overlap in case upperValueLabel is at the maximum boundary
                let newOverlap = lowerValueLabel.frame.maxX - upperValueLabel.frame.minX + 4
                let diff = abs(newOverlap / 2 - previousLabelsOverlap / 2)
                lowerValueLabel.frame = getLowerValueLabelFrame(newOverlap / 2 + diff)
            } else {
                upperValueLabel.alignmentMode = .center
                lowerValueLabel.frame = getLowerValueLabelFrame(0)
            }
            
        case .none: break
        }
    }


    private func animateSize(of thumb: CALayer, isTracking: Bool) {
        let transform: CATransform3D
        if isTracking {
            transform = CATransform3DMakeScale(thumbDiameterMultiplier, thumbDiameterMultiplier, 1.0)
        } else {
            transform = CATransform3DIdentity
        }
        
        let diff = self.previousLabelsOverlap > 0 ? self.previousLabelsOverlap : 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            thumb.transform = transform
            if thumb == self.rightThumb {
                self.upperValueLabel.frame = self.getUpperValueLabelFrame(diff / 2)
            } else {
                self.lowerValueLabel.frame = self.getLowerValueLabelFrame(diff)
            }
            self.layoutIfNeeded()
        }, completion: { _ in })
    }
    
    
    func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopController(base: presented)
        }
        return base
    }

    func getTopController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return nav.visibleViewController
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return selected
        } else if let presented = base?.presentedViewController {
            return getTopController(base: presented)
        }
        return base
    }
}






// MARK: - Extensions

public extension CGPoint {
    func distance(to: CGPoint) -> CGFloat {
        let distX: CGFloat = to.x - x
        let distY: CGFloat = to.y - y
        return sqrt(distX * distX + distY * distY)
    }
}

public extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

public extension UIImage {
    /*** Call this to prevent quality loss ***/
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
    func resizedImage(newSize: CGSize) -> UIImage {
        // guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        return newImage
    }
}
