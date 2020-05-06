//
//  DemoViewController.swift
//  DemoProject
//
//  Created by george on 30/04/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit
import GNRangeSlider

class DemoViewController: UIViewController {
    
    lazy var rangeSlider: GNRangeSlider = {
        let s = GNRangeSlider(textPosition: .top, tracking: .animatable)
        s.minimumValue = -10
        s.maximumValue = 10
        s.lowerValue = -7
        s.upperValue = 4
        s.step = 0.5
        s.minimumSelectedRange = 1
        s.trackColor = UIColor.blue.withAlphaComponent(0.4)
        s.trackHighlightedColor = UIColor.blue
        s.trackCurvature = 1
        s.trackThickness = 8
        s.thumbDiameter = 40
        s.thumbDiameterMultiplier = 1.2
        s.thumbImage = #imageLiteral(resourceName: "apple_icon")
        s.thumbColor = UIColor.purple
        s.thumbBorderColor = UIColor.red
        s.thumbBorderWidth = 2
        s.thumbCurvature = 1
        s.textFont = UIFont(name: "Chalkduster", size: 14) ?? s.textFont
        s.textColor = UIColor.darkGray
        s.numberFormatter.currencySymbol = "€"
        s.numberFormatter.numberStyle = .currency
        s.shouldTextClipToBounds = true
        s.delegate = self
        return s
    }()
    
    lazy var rangeSlider2: GNRangeSlider = {
        let s = GNRangeSlider(textPosition: .bottom, tracking: .snapping)
        s.minimumValue = 10
        s.maximumValue = 100
        s.lowerValue = 10
        s.upperValue = 100
        s.step = 0
        s.minimumSelectedRange = 20
        s.trackColor = UIColor.lightGray.withAlphaComponent(0.6)
        s.trackHighlightedColor = UIColor.systemBlue
        s.trackCurvature = 1
        s.trackThickness = 6
        s.thumbDiameter = 24
        s.thumbDiameterMultiplier = 1
        s.thumbColor = UIColor.systemRed
        s.thumbBorderColor = UIColor.black
        s.thumbBorderWidth = 0
        s.thumbCurvature = 1
        s.textFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        s.textColor = UIColor.blue
        s.numberFormatter.maximumFractionDigits = 0
        s.numberFormatter.minimumFractionDigits = 0
        s.shouldTextClipToBounds = false
        s.delegate = self
        return s
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.backgroundColor = .white
        view.addSubview(rangeSlider)
        view.addSubview(rangeSlider2)

        rangeSlider.translatesAutoresizingMaskIntoConstraints = false
        [rangeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         rangeSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
         rangeSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
        ].forEach({ $0.isActive = true })
        
        rangeSlider2.translatesAutoresizingMaskIntoConstraints = false
        [rangeSlider2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         rangeSlider2.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
         rangeSlider2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),
        ].forEach({ $0.isActive = true })

    }
}


// MARK: - GNRangeSliderDelegate

extension DemoViewController: GNRangeSliderDelegate {
    func didBeginTracking(in slider: GNRangeSlider) {
        print("------ Begin tracking ------")
    }
    
    func didEndTracking(in slider: GNRangeSlider) {
        print("------ End tracking --------")
    }
    
    func didTrackingValuesChange(_ slider: GNRangeSlider, lowerValue: CGFloat, upperValue: CGFloat) {
        print("\(lowerValue) - \(upperValue)")
    }
}
