Pod::Spec.new do |spec|

  spec.name         = "GNRangeSlider"
  spec.version      = "0.1.1"
  spec.summary      = "A fully customisable range slider"
  spec.description  = <<-DESC
  This library can be used to show a double thumb slider to provide range input.
                   DESC
  spec.homepage     = "https://github.com/nicolaouG/GNRangeSlider"
  spec.screenshots  = "https://raw.githubusercontent.com/nicolaouG/GNRangeSlider/master/rangeSlider.gif"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "george" => "georgios.nicolaou92@gmail.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5"
  spec.source       = { :git => "https://github.com/nicolaouG/GNRangeSlider.git", :tag => "#{spec.version}" }
  spec.source_files = "GNRangeSlider/**/*.{h,m,swift}"
  spec.framework    = "UIKit"
  spec.requires_arc = true

end