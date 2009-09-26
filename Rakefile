require "rubygems"
require "rake"
require "rake/gempackagetask"
require "rake/testtask"
require "yard"

PKG_VERSION = "0.0.1"
PKG_FILES = Dir[File.join("lib", "**", "*.rb")] + Dir[File.join("test", "**", "*.rb")]

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Functional Testing is Futile!"
  s.name = "futile"
  s.version = PKG_VERSION
  s.requirements << "none"
  s.require_path = "lib"
  s.files = PKG_FILES
  s.description = "Test your websites with *real* functional tests"
  s.author = "Michal Bugno & Pawel Obrok"
  s.email = "michal.bugno@gmail.com & pawel.obrok@gmail.com"
  s.homepage = "http://github.com/obrok/futile"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList[File.join("test", "*_test.rb")]
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
end

desc 'Default: run tests'
task :default => 'test'

desc "Clean files which can be generated"
task :clean do
  FileUtils.rm_rf("pkg")
  FileUtils.rm_rf("doc")
end

desc "Run tests, generate doc and build gem"
task :release => [:clean, :test, :yardoc, :gem]
