
Pod::Spec.new do |s|

s.name         = "FPSStatusBar"
s.version      = "4.0.0"
s.summary      = "show FPS at StatusBar."

s.homepage     = "https://github.com/asaday/FPSStatusBar"
s.license     = { :type => "MIT" }
s.author       = { "asaday" => "" }

s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/asaday/FPSStatusBar.git", :tag => s.version }
s.source_files  = "classes/**/*.{swift,h,m}"
s.requires_arc = true


end
