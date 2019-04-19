require 'bundler/gem_tasks'
require 'fileutils'
require 'rake/extensiontask'
require 'rspec/core/rake_task'

task :copy_native do
  src = 'ext/ductwork/native/src/'
  dest = 'ext/ductwork/'

  Dir["#{src}*"].each do |path| 
    name = path.split('/').last
    FileUtils.cp(path, dest + name)
  end
end

task compile: :copy_native

Rake::ExtensionTask.new 'ductwork' do |ext|
  ext.lib_dir = 'lib/ductwork'
end

RSpec::Core::RakeTask.new(:spec)

task default: [ :clean, :compile, :spec ]
