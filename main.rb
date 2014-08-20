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
		@client.query('use ' + db)
		@client.query('describe ' + tbl).to_a
	end

	def dump(db, tbl)
		@client.query('use ' + db)
		@client.query('select * from ' + tbl).to_a
	end

	def escape(str)
		@client.escape(str.to_s)
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
			[ 'struct.sql', 'struct.json', 'dump.sql', 'dump.json' ]
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

		if path[2] == 'struct.sql'
			# TODO indexes etc
			"CREATE TABLE [#{path[1]}] (\n\t" + @db.struct( path[0], path[1] ).map do |fld|
				str = "[#{fld['Field']}] #{fld['Type']}"
				str += ' NOT NULL' if fld['Null'] == 'NO'
				str += ' DEFAULT ' + fld['Default'] if fld['Default']
				str += ' PRIMARY KEY' if fld['Key'] == 'PRI'
				str
			end.join(",\n\t") + "\n);"
		elsif path[2] == 'struct.json'
			JSON.pretty_generate( @db.struct( path[0], path[1] ) )
		elsif path[2] == 'dump.sql'
			data = @db.dump( path[0], path[1] )
			keys = data.first.keys

			"INSERT INTO [#{path[1]}] ( [#{keys.join('], [')}] ) VALUES\n\t" + data.map do |row|
				'("' + keys.map do |k|
					@db.escape( row[k] )
				end.join('", "') + '")'
			end.join(",\n\t") + ";"
		elsif path[2] == 'dump.json'
			JSON.pretty_generate( @db.dump( path[0], path[1] ) )
		else
			nil
		end + "\n" #rescue ""
	end

end

# Usage: #{$0} mountpoint [mount_options]
FuseFS.main() do |options|
	DBListDir.new( MysqlDB.new )
end
