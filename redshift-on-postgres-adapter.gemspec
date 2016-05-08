$LOAD_PATH.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
 s.name        = 'redshift-on-postgres-adapter'
 s.version     = '0.1.0'
 s.license     = 'New BSD License'
 s.date        = '2016-05-07'
 s.summary     = "Rails 5 RedShift adapter based on current postgresql adapter."
 s.description = "This gem provides ActiveRecord adapter for RedShift by overloading the postgresql adapter."
 s.authors     = ["Dongyi Liao"]
 s.email       = 'liaody@gmail.com'
 s.files       = %w[lib/active_record/connection_adapters/redshift_adapter.rb lib/active_record/tasks/redshift_database_tasks.rb]
 s.require_path = 'lib'
 s.homepage    = 'http://github.com/liaody'
 s.add_dependency "pg"
 s.add_dependency "activerecord"
end
