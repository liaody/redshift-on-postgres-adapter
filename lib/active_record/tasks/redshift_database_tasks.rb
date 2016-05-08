require 'active_record/tasks/postgresql_database_tasks'

class ActiveRecord::Tasks::RedshiftDatabaseTasks < ActiveRecord::Tasks::PostgreSQLDatabaseTasks # :nodoc:
  def initialize(configuration)
    super
  end
end