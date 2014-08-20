#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'bundler/setup'
Bundler.require(:default)

class MysqlDB

	def initialize()
		@client = Mysql2::Client.new( :host => "localhost", :username => "root", :password => 01216464.to_s )
	end

	def databases()
		@client.query('show databases').map { |v| v['Database'] }
	end

	def tables(db)
		@client.query('use ' + db)
		@client.query('show tables').map { |v| v.values.first }
	end

	def struct(db, tbl)
		'123'
	end

	def dump(db, tbl)
		'-- ne'
	end

	def json(db, tbl)
		'{}'
	end

end

class DBListDir

	def initialize(db)
		@db = db
	end

	def _path_split(path)
		path.split('/').select { |v| v != '' }.to_a
	end

	def contents(path)
		path = _path_split(path)

		if path.empty?
			@db.databases
		elsif path.size == 1
			@db.tables( path[0] )
		elsif path.size == 2
			[ 'struct', 'dump', 'json' ]
		else
			[]
		end
	end

	def directory?(path)
		path = _path_split(path)

		path.size < 3
	end

	def file?(path)
		path = _path_split(path)

		path.size == 3
	end

	def read_file(path)
		path = _path_split(path)
		p path

		if path[2] == 'struct'
			@db.struct( path[0], path[1] )
		elsif path[2] == 'dump'
			@db.dump( path[0], path[1] )
		elsif path[2] == 'json'
			@db.json( path[0], path[1] )
		else
			nil
		end + "\n" rescue ""
	end

end

# Usage: #{$0} mountpoint [mount_options]
FuseFS.main() do |options|
	DBListDir.new( MysqlDB.new )
end
