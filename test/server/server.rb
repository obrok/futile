require "rubygems"
require "erb"
require "webrick"

include WEBrick
module TestServer
  def self.parse_erb(path, context = {})
    erb = ERB.new(File.read("test/server/%s" % [path]))
    context.each { |k, v| eval("%s = %s" % [k, v]) }
    erb.result(binding)
  end

  SERVER = HTTPServer.new({:Port => 6666,
                           :Logger => Log.new(nil, BasicLog::WARN),
                           :AccessLog => [],
                          })

  ["INT", "TERM"].each { |signal|
    trap(signal) { SERVER.shutdown }
  }

  SERVER.mount_proc("/simple_get") do |req, resp|
    resp.body = parse_erb("simple_html.erb")
  end

  SERVER.mount_proc("/second_page") do |req, resp|
    resp.body = parse_erb("second_page.erb")
  end

  SERVER.mount_proc("/infinite_redirect") do |req, resp|
    resp["Location"] = "/infinite_redirect"
    resp.status = 302
  end

  SERVER.mount_proc("/single_redirect") do |req, resp|
    resp["Location"] = "/simple_get"
    resp.status = 302
  end

  SERVER.mount_proc("/nested_path/index.html") do |req, resp|
    resp.body = parse_erb("nested_path.erb")
  end

  SERVER.mount_proc("/nested_path/nested_in.html") do |req, resp|
    resp.body = parse_erb("nested_path.erb")
  end

  def self.content=(value)
    @@content = value
  end

  SERVER.mount_proc("/form") do |req, resp|
    resp.body = parse_erb("form.erb")
  end

  SERVER.mount_proc("/form_without_method") do |req, resp|
    resp.body = parse_erb("form_without_method.erb")
  end

  SERVER.mount_proc("/doit") do |req, resp|
    resp.body = "<html><body>" + req.request_method
    req.query.each do |k, v|
      v.each_data do |d|
        resp.body += "\n#{k}:#{d}"
      end
    end
    resp.body += "</body></html>"
  end

  SERVER.mount_proc("/referer") do |req, resp|
    resp.body = "<html><body>" + req["Referer"].to_s + "</body></html>"
  end

  SERVER.mount_proc("/request_headers") do |req, resp|
    resp.body = "<html><body>\n"
    req.header.each do |key, value|
      resp.body << "%s => %s\n" % [key.downcase, value]
    end
    resp.body << "</body></html>"
  end

  SERVER.mount_proc("/scoped_links") do |req, resp|
    resp.body = parse_erb("scoped_links.erb")
  end

  Thread.fork do
    SERVER.start
  end
end
