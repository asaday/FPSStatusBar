
Pod::Spec.new do |s|

s.name         = "FPSStatusBar"
s.version      = "0.0.2"
s.summary      = "show FPS at StatusBar."

s.homepage     = "https://github.com/asaday/FPSStatusBar"
s.screenshots  = "github.com/asaday/FPSStatusBar/master/docs/ss.png"
s.license     = { :type => "MIT" }
s.author       = { "asaday" => "" }

s.platform     = :ios, "8.0"
s.source       = { :git => "http://github.com/asaday/FPSStatusBar.git", :tag => s.version }
s.source_files  = "classes/**/*.{swift,h,m}"
s.preserve_paths = "modules/module.modulemap"
s.requires_arc = true

s.xcconfig= {
  "SWIFT_INCLUDE_PATHS" =>    "${PODS_ROOT}/FPSStatusBar/modules" 
  }

end
