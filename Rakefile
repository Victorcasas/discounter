require 'rake/testtask'

task :default => 'specs'

Rake::TestTask.new('specs') do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
end
