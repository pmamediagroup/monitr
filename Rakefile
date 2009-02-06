require 'rubygems'
require 'hoe'

Hoe.new('monitr', '0.7.12') do |p|
  p.rubyforge_name = 'monitr'
  p.author = 'Tom Preston-Werner'
  p.email = 'tom@rubyisawesome.com'
  p.url = 'http://monitr.rubyforge.org/'
  p.summary = 'Like monit, only awesome'
  p.description = "Monitr is an easy to configure, easy to extend monitoring framework written in Ruby."
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.spec_extras = {:extensions => ['ext/monitr/extconf.rb']}
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/monitr.rb"
end

desc "Upload site to Rubyforge"
task :site do
  sh "scp -r site/* mojombo@monitr.rubyforge.org:/var/www/gforge-projects/monitr"
end

desc "Upload site to Rubyforge"
task :site_edge do
  sh "scp -r site/* mojombo@monitr.rubyforge.org:/var/www/gforge-projects/monitr/edge"
end

desc "Run rcov"
task :coverage do
  `rm -fr coverage`
  `rcov test/test_*.rb`
  `open coverage/index.html`
end