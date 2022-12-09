#!/usr/bin/env ruby

require 'net/https'
require 'json'
require 'open-uri'
require 'uri'
require 'optparse'
require 'fileutils'

options = {}

opts = OptionParser.new do |o|
    o.banner = "Usage: #{$0} [OPTIONS]"
    o.separator ""
    o.on("-c", "--credentials-file CREDENTIALS", "Credentials file for authenticating against the Jenkins server") {|v| options[:creds] = v}
    o.on("-s", "--ssogen-dir SSOGEN_DIR", "Directory to place SSOGenerator in") {|v| options[:ssogendir] = v}
    o.on_tail("-h", "--help", "Show this help message") do
        puts o
        exit
    end
end

begin
    opts.parse! ARGV
    raise OptionParser::MissingArgument, 'CREDENTIALS' if options[:creds].nil?
    raise OptionParser::MissingArgument, 'CREDENTIALS' if options[:ssogendir].nil?

    options[:creds] = File.expand_path(options[:creds])
    options[:ssogendir] = File.expand_path(options[:ssogendir])

    raise ArgumentError, 'CREDENTIALS' if not File.exist?(options[:creds])
    raise ArgumentError, 'SSOGEN_DIR' if not Dir.exist?(options[:ssogendir])
rescue => arg_err
    puts "#{arg_err.message}"
    puts opts
    exit
end


aduser = ""
adpass = ""

begin
    File.readlines(options[:ssogendir] + "/credentials").each do |line|
        creds = line.split("=")
        case creds[0]
        when "ADUSERNAME"
            aduser = creds[1].chomp!
        when "ADPASSWORD"
            adpass = creds[1].chomp!
        end
    end
    
    if aduser.empty? or adpass.empty?
        raise ArgumentError
    end
rescue => arg_err
    puts "#{arg_err.message}"
    puts opts
    exit
end

base_uri = 'https://linux-auth-nva.gov.prd.aws.asurion.net/jenkins/job/system/job/aws-utils/lastSuccessfulBuild'
list_uri = "#{base_uri}/api/json?tree=artifacts%5BrelativePath%5D"
download_uri = ''

artifact_list_uri = URI.parse(list_uri)

http = Net::HTTP.new(artifact_list_uri.host, artifact_list_uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(artifact_list_uri.request_uri)
request.basic_auth(aduser, adpass)

begin
    artifacts_list = JSON.parse(http.request(request).body)
    artifacts_list['artifacts'].each do |a|
        if a['relativePath'].downcase.include? 'ssogenerator'
            download_uri = "#{base_uri}/artifact/#{a['relativePath']}"
        end
    end
rescue 
    puts "Error checking for new version of SSOGenerator. No changes made to SSOGenerator."
    exit 1
end

latest_version = download_uri.split('/')[-1]
if not Dir.entries(options[:ssogendir]).include? latest_version
    puts "Downloading new version of SSOGenerator: #{latest_version}"

    artifact_uri = URI.parse(download_uri)
    request = Net::HTTP::Get.new(artifact_uri.request_uri)
    request.basic_auth(aduser, adpass)

    savefile = options[:ssogendir] + '/' + latest_version

    f = File.open(savefile, 'w')
    begin
        http.request(request) do |res|
            res.read_body do |seg|
                f.write(seg)
            end
        end
        FileUtils.ln_s  savefile, "#{options[:ssogendir]}/SSOGenerator.jar", force: true
    ensure
        f.close()
    end

end

