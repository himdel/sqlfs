sqlfs - fuse mountable filesystem to interact with sql databases

The code is very young but the following already works:

   * mysql support (via mysql2)
   * fuse support (via rfusefs)
   * listing databases and tables
   * structure and data for each table, in sql and json files


TODO:

   * postgresql support
   * proper escaping of generated sql
   * refactor to add another layer between db and fuse - DBListDir was supposed to be full of other \*Dir and \*File objects, not handle everything
   * accessing individual rows, read-write access, etc.


Instructions:

   * in debian, you need `ruby-dev`, `bundler`, `libmysqlclient-dev` (or `libmariadbclient-dev`)
   * unpack, run `bundle install`
   * `sudo ruby main.rb /media/db -o allow_other`
   * ...
   * profit
