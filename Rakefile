require 'bundler/gem_tasks'
require 'rake/extensiontask'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

Rake::ExtensionTask.new 'ductwork' do |ext|
  ext.lib_dir = 'lib/ductwork'
end

task default: [ :clean, :compile, :spec ]
