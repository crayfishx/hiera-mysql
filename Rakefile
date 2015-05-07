require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |gem|
    gem.name = "hiera-mysql"
    gem.version = "1.0.0"
    gem.summary = "MySQL backend for Hiera"
    gem.email = "craig@craigdunn.org"
    gem.author = "Craig Dunn"
    gem.homepage = "http://github.com/crayfishx/hiera-mysql"
    gem.description = "Hiera back end for retrieving configuration values from MySQL"
    gem.require_path = "lib"
    gem.files = FileList["lib/**/*"].to_a
    gem.add_dependency('mysql')
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

