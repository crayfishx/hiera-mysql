require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |gem|
    gem.name = "hiera-mysql"
    gem.version = "2.0.1"
    gem.summary = "MySQL backend for Hiera"
    gem.email = "craig@craigdunn.org"
    gem.author = "Craig Dunn"
    gem.homepage = "http://github.com/crayfishx/hiera-mysql"
    gem.description = "Hiera back end for retrieving configuration values from MySQL"
    gem.require_path = "lib"
    gem.files = FileList["lib/**/*"].to_a
    gem.requirements << 'mysql'
    gem.requirements << 'jdbc-mysql'
end

Gem::PackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end
