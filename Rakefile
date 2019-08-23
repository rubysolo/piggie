require "bundler/gem_tasks"
task default: :spec

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rrubygems -I lib -r piggie.rb"
end
