$:.unshift File.expand_path("../lib", __FILE__)
require "barcode_server/version"

Gem::Specification.new do |s|
  s.name = "barcode_server"
  s.version = BarcodeServer::VERSION
  s.summary = "Rack-based barcode server"

  s.files = Dir["lib/**/*.rb"]

  s.add_dependency "barby", "~> 0.5"
  s.add_dependency "rqrcode", "~> 0.4"
  s.add_dependency "cairo", "~> 1.12"
  s.add_dependency 'chunky_png', '~> 1.2'

  s.add_development_dependency "rspec"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "nokogiri"

  s.authors = ["Anthony Fojas"]
  s.email = ["anthony.fojas@vibes.com"]
end
