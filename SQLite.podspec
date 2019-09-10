Pod::Spec.new do |spec|
  spec.name = 'SQLite'
  spec.version  = '0.9.0'
  spec.author = 'Werner Freytag'
  spec.homepage = 'https://github.com/werner-freytag/SQLite'
  spec.documentation_url = 'https://github.com/werner-freytag/SQLite'
  spec.summary = 'A lightweight Swift wrapper for SQLite.'
  spec.description = <<-DESC
                     A lightweight Swift wrapper for SQLite. Makes use of Swift generics and errors. Can fetch data lazy or at once, depending on what you prefer.
                     DESC
  spec.source = { :git => 'https://github.com/werner-freytag/SQLite.git', :tag => "#{spec.version}" }
  spec.license = "MIT"
  spec.swift_versions = ['5.0']

  spec.ios.deployment_target = '9.0'
  spec.osx.deployment_target = '10.10'
end
