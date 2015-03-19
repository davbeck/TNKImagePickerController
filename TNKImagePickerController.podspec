Pod::Spec.new do |s|
  s.name             = "TNKImagePickerController"
  s.version          = "0.2.0"
  s.summary          = "A replacement for UIImagePickerController that can select multiple photos."
  s.homepage         = "https://github.com/davbeck/TNKImagePickerController"
  s.screenshots      = "http://f.cl.ly/items/3c1h0N2X0N0y0a1U240P/IMG_0011.PNG", "http://f.cl.ly/items/0U473h2X2u211g3A1n0j/IMG_0012.PNG", "http://f.cl.ly/items/2n0A372v151R1P3p0g0o/IMG_0013.PNG"
  s.license          = 'MIT'
  s.author           = { "David Beck" => "code@thinkultimate.com" }
  s.source           = { :git => "https://github.com/davbeck/TNKImagePickerController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/davbeck'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'TNKImagePickerController' => ['Pod/Assets/*']
  }
  
  s.frameworks = 'UIKit', 'Photos'
  s.dependency 'TULayoutAdditions', '~> 0.2'
end
