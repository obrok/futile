require "rubygems"
require "webrick"

server = WEBrick::HTTPServer.new(:Port => 6666)

["INT", "TERM"].each { |signal|
  trap(signal) { server.shutdown }
}

server.mount_proc("/simple_get") do |req, resp|
  resp.body = "get response"
end

server.mount_proc("/infinite_redirect") do |req, resp|
  resp["Location"] = "/infinite_redirect"
  resp.status = 302
end

server.start
