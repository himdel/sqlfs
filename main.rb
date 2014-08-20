#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'rfusefs'

class HelloDir

	def contents(path)
		['hello.txt']
	end

	def file?(path)
		path == '/hello.txt'
	end

	def read_file(path)
		"Hello, World!\n"
	end

end

# Usage: #{$0} mountpoint [mount_options]
FuseFS.main() do |options|
	HelloDir.new
end
