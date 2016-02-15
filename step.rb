require 'net/http'
require 'net/https'
require 'json/ext'

def sendPutRequest(url, body=nil)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.ssl_version = :TLSv1
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Put.new(uri.path)
  req['Authorization'] = "token #{@authorization_token}"
  req.body = body unless body.nil?

  http.request(req)
end

def sendGetRequest(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.ssl_version = :TLSv1
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  req = Net::HTTP::Get.new(uri.path)
  req['Authorization'] = "token #{@authorization_token}"

  http.request(req)
end

url = ENV["repository_url"]
if url.to_s.eql? ''
  puts "No repository url specified :>#{url}<"
  exit 1
end

unless (/([A-Za-z0-9]+@|http(|s)\:\/\/)(github.com)(:|\/)(?<user>[A-Za-z0-9]+)\/(?<repo>[^.]+)(\.git)?/ =~ url) == 0
  puts "#{url} is not a GitHub repository"
  exit 1
end

build_is_green = ENV["STEPLIB_BUILD_STATUS"] == "0"
commit_hash = ENV["commit_hash"]
@authorization_token = ENV["auth_token"]
pull_id = ENV["pull_id"]

if commit_hash.to_s.eql? ''
  puts "No commit hash specified"
  exit 1
end

if @authorization_token.to_s.eql? ''
  puts "No authorization_token specified"
  exit 1
end

if pull_id.to_s.eql? ''
  puts "No build url specified"
  exit 1
end


#lecture pull/number
url = "https://api.github.com/repos/#{user}/#{repo}/pulls/#{pull_id}"
response = sendGetRequest url
data = JSON.parse response.body
statuses_url=data["statuses_url"]
puts data["mergeable_state"]

#lecture statuses
#if state == success
#  merge
#end


  commit_hash = statuses_url.split('/').last
  url= "https://api.github.com/repos/#{user}/#{repo}/pulls/#{pull_id}/merge"
  body = {
    commit_message:"merged by BBM",
    sha: commit_hash
  }.to_json
  puts url +" " + body
  response = sendPutRequest url, body
  exit (response.code.eql?('200') ? 0 : 1)

