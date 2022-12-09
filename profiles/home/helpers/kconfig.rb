#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require 'pp'
require 'fileutils'

options = {}

opts = OptionParser.new do |o|
    o.banner = "Usage: #{$0} [OPTIONS]"
    o.separator ""
    o.on("-c", "--context CONTEXT", "Context name to be changed") {|v| options[:context] = v}
    o.on("-n", "--name NAME", "The new name for the selected context") {|v| options[:newname] = v}
	o.on("-l", "--list", "List contexts") {|v| options[:list] = true}
    o.on_tail("-h", "--help", "Show this help message") do
        puts o
        exit
    end
end

begin
    opts.parse! ARGV
    bad_combo = false
    if (options[:context].nil? && options[:list].nil?) || (!options[:context].nil? && !options[:list].nil?) then
        bad_combo = true
    end
    raise OptionParser::MissingArgument, 'must have either CONTEXT or -l flag but not both' if bad_combo
    raise OptionParser::MissingArgument, 'must specify new NAME' if !options[:context].nil? && options[:newname].nil?
rescue => arg_err
    puts "#{arg_err.message}"
    puts opts
    exit
end

base_path = File.expand_path('~/.kube')
cfgfile = "#{base_path}/config"
kconfig = YAML.load_file(cfgfile)
kcontexts = kconfig['contexts']

if options[:list] then
    (kcontexts.sort_by {|k| k['name']}).map {|c| puts c['name']}
else
    bakfile = "#{base_path}/config-#{DateTime.now.to_s}"
    puts "Backing up #{cfgfile} to #{bakfile}"
    FileUtils.cp cfgfile, bakfile
    current_context = kconfig['current-context']
    kcontexts.map {|c| c['name'] = options[:newname] if c['name'] == options[:context]}
    if current_context == options[:context]
        kconfig['current-context'] = options[:newname] 
    end
    File.open(cfgfile, 'w') do |f|
        f.write(kconfig.to_yaml)
    end
end

