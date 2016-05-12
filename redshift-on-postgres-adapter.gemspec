$LOAD_PATH.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
 s.name        = 'redshift-on-postgres-adapter'
 s.version     = '0.2.0'
 s.license     = 'New BSD License'
 s.date        = '2016-05-07'
 s.summary     = "This gem provides ActiveRecord adapter for Redshift by overloading the built-in Rails 5 PostgreSQL adapter."
 s.description = "Rails 5 Amazon Redshift adapter based on built-in postgresql adapter."
 s.authors     = ["Dongyi Liao"]
 s.email       = 'liaody@gmail.com'
 s.files       = Dir['lib/active_record/connection_adapters/**/*.rb']
 s.require_path = 'lib'
 s.homepage    = 'https://github.com/liaody/redshift-on-postgres-adapter'
 s.add_dependency "pg"
 s.add_dependency "activerecord"
end
