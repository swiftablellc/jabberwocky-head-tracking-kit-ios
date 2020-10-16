Pod::Spec.new do |spec|
  spec.name         = "JabberwockyHTKit"
  spec.version      = "0.8.0"
  spec.summary      = "Jabberwocky Head Tracking Kit for iOS"

  spec.description  = <<-DESC
The Jabberwocky® Head Tracking Kit (JabberwockyHTKit) is an open-source iOS framework, developed by Swiftable LLC, that provides a touch-free interface for existing iOS applications. Jabberwocky enables users to interact with an application by just moving their head. Head movement translates into the movement of a mouse-like cursor on the screen. By default, blinks trigger a .touchUpInside event simulating a tap on any UIControl subclass (in fact any subclass of UIView can be extended to respond to a facial gesture trigger).
                   DESC

  spec.homepage     = "https://www.jabberwockyapp.com"
  spec.license      = {
    :type => "Copyright",
    :text => <<-LICENSE
Copyright 2020 Swiftable, LLC. <contact@swiftable.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
      LICENSE
  }

  spec.authors      = { "Jonathan Hoag" => "jon@swiftable.org", "Aaron Chavez" => "aaron@swiftable.org" }
  spec.source       = { :git => "https://github.com/swiftablellc/jabberwocky-head-tracking-kit-ios.git", :tag => "#{spec.version}" }

  spec.source_files  = "JabberwockyHTKit*/**/*.{swift}"
  spec.resources = "JabberwockyHTKit*/**/*.{xcassets,scnassets}"
  spec.vendored_frameworks = "JabberwockyARKitEngine.xcframework"

  spec.ios.deployment_target = "9.0"
  spec.swift_version = "5.2"

end
