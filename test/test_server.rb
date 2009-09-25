require "rubygems"
require "webrick"

include WEBrick
module TestServer
  SERVER = HTTPServer.new(:Port => 6666, 
                          :Logger => Log.new(nil, BasicLog::WARN),
                          :AccessLog => [])

  ["INT", "TERM"].each { |signal|
    trap(signal) { server.shutdown }
  }

  SERVER.mount_proc("/simple_get") do |req, resp|
    resp.body = "get response"
  end

  SERVER.mount_proc("/infinite_redirect") do |req, resp|
    resp["Location"] = "/infinite_redirect"
    resp.status = 302
  end

  SERVER.mount_proc("/single_redirect") do |req, resp|
    resp["Location"] = "/simple_get"
    resp.status = 302
  end

  def self.content=(value)
    @@content = value
  end

  SERVER.mount_proc("/") do |req, resp|
    resp.body = @@content
    resp.status = 200
  end

  Thread.fork do
    SERVER.start
  end
end
