$LOAD_PATH.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
 s.version     = '0.2.2'
 s.date        = '2016-05-13'

 s.name        = 'redshift-on-postgres-adapter'
 s.license     = 'BSD-2-Clause'
 s.summary     = "This gem provides ActiveRecord adapter for Redshift by overloading the built-in Rails 5 PostgreSQL adapter."
 s.description = "Rails 5 Amazon Redshift adapter based on built-in postgresql adapter."
 s.authors     = ["Dongyi Liao"]
 s.email       = 'liaody@gmail.com'
 s.files       = Dir['lib/active_record/**/*.rb']
 s.require_path = 'lib'
 s.homepage    = 'https://github.com/liaody/redshift-on-postgres-adapter'
 s.add_dependency "pg", '~> 0.18'
 s.add_dependency "activerecord"
end
