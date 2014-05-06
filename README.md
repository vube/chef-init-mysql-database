# chef-init-mysql-database

Easily install and configure Mysql Databases via this Chef cookbook.


## Configuration

To configure this cookbook requires a mysql_database data_bag with two
data sets.

### `data_bags/mysql_database/users.json`

In this data_bag_item you list out all of the users that you want to
create, their passwords and the hosts from which they should be allowed
to connect.

#### Example

```json
{
	"id": "users",
    "users": [
		{
			"name": "{INSERT_USERNAME_HERE}",
			"password": "{INSERT_PASSWORD_HERE}",
			"hosts": ["localhost"]
		}
	]
}
```

### `data_bags/mysql_database/databases.json`

In this data_bag_item you list out all of the databases that you want
to create/initialize.

The `init.sql` directive can be either a path to a file or a path to
a Dir.glob that expands to multiple filenames, as seen below.
This SQL will only be run when the DB contains no content (e.g. when
there are no tables in it, probably the fist time you `vagrant up`)

The permissions are a list of all of the permissions you want for each
user to have on this database.  List as many users as you need and give
the users only the permissions they require.  See the MySQL user manual
for a complete list of permissions you may grant.

#### Example

```json
{
    "id": "databases",
    "databases": {
        "forums": {
            "init.sql": "/path/to/app/*.sql",
            "permissions": [
                {
                    "username": "{INSERT_USERNAME_HERE}",
                    "permissions": [
                        "select", "insert", "update", "delete",
                        "create", "drop", "index", "alter",
                        "create temporary tables", "lock tables",
                        "execute", "show view", "trigger"
                    ]
                }
            ]
        }
    }
}
```


## Usage

The easiest way to use this is to include it as a submodule in your project.
Makes sure you put it somewhere in your cookbook search path.

For example:

```bash
$ git submodule add https://github.com/vube/chef-init-mysql-database
```

Then you will want to list this as a dependency in your `metadata.rb`

```ruby
depends "chef-init-mysql-database"
```

Finally, you need to include this recipe from one of the recipes on your run list.

```ruby
include_recipe "chef-init-mysql-database"
```
