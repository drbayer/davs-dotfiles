#!/usr/bin/env ruby
require_relative 'modules/dav.rb'

module Fred
    include Dav

    def say_hello(guy)
        opts = Opts.new
        opts.hello(guy)
    end
end

Fred.say_hello('doofus')

