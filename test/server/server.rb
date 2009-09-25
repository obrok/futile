require "rubygems"
require "erb"
require "webrick"

def parse_erb(path, context = {})
  erb = ERB.new(File.read("test/server/%s" % [path]))
  context.each { |k, v| eval("%s = %s" % [k, v]) }
  erb.result(binding)
end

server = WEBrick::HTTPServer.new(:Port => 6666)

["INT", "TERM"].each { |signal|
  trap(signal) { server.shutdown }
}

server.mount_proc("/simple_get") do |req, resp|
  resp.body = parse_erb("simple_html.erb")
end

server.mount_proc("/infinite_redirect") do |req, resp|
  resp["Location"] = "/infinite_redirect"
  resp.status = 302
end

server.mount_proc("/single_redirect") do |req, resp|
  resp["Location"] = "/simple_get"
  resp.status = 302
end

server.start
