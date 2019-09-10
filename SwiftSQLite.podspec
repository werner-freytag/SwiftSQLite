Pod::Spec.new do |spec|
    spec.name = 'SwiftSQLite'
    spec.version  = '0.9.1'
    spec.author = 'Werner Freytag'
    spec.homepage = 'https://github.com/werner-freytag/SwiftSQLite'
    spec.documentation_url = 'https://github.com/werner-freytag/SwiftSQLite'
    spec.summary = 'A lightweight Swift wrapper for SQLite.'
    spec.description = <<-DESC
        A lightweight Swift wrapper for SQLite. Makes use of Swift generics and errors. Can fetch data lazy or at once, depending on what you prefer.
    DESC
    spec.source = { :git => 'https://github.com/werner-freytag/SwiftSQLite.git', :tag => "#{spec.version}" }
    spec.license = "MIT"
    spec.swift_versions = ['5.0']
    spec.source_files  = "Sources/**/*"
    spec.ios.deployment_target = '9.0'
    spec.osx.deployment_target = '10.10'
end
