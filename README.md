# redshift-on-postgres-adapter

In Rails 5 the PostgreSQL database adapter is built in. This gem tries to use that as a base and modify just enough things to talk to Amazon Redshift.

### Examples

```ruby
class AddNewColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :my_table, :new_col, :int, null: false, default: 0, encode: :runlength
  end
end
```


### Tested
* Table loading
* Adding, removing records
* Drop tables
* Migrations
* Column encoding support.
* DISTKEY and SORTKEY

### TODO
* Schema dumping with .rb with correct encoding and key signature.


### Changes

0.2.0:
* Support column options of :distkey, :sortkey, and :encode

0.1.1:
* Support auto incrementing primary keys in DB creation

0.1.0:
* Original Version
