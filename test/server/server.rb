require "rubygems"
require "erb"
require "webrick"

class WebServer
  attr_reader :server

  def initialize(port = 6666)
    @server = WEBrick::HTTPServer.new(
      {:Port => port,
        :Logger => WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
        :AccessLog => [],
    })
    ["INT", "TERM"].each { |signal| trap(signal) { server.shutdown } }
    mount("/favicon.ico") { }
  end

  def page(path, content = nil, opts = {})
    layout_name = opts[:layout] || "layout.erb"
    mount(path) do |request, response|
      @request, @response = request, response
      yield request, response if block_given?
      if content.nil?
        # do nothing
      elsif content[-3 .. -1] == "erb"
        layout = ERB.new(File.read(File.join("test", "server", "erb", layout_name)))
        erb = ERB.new(File.read(File.join("test", "server", "erb", content)))
        @content = erb.result(binding)
        response.body = layout.result(binding)
      else
        response.body = File.read(File.join("test", "server", content))
      end
    end
  end

  def redirect(from, to, permanent = false)
    mount(from) do |request, response|
      response.status = permanent ? 301 : 302
      response["Location"] = to
    end
  end

  def mount(path, &block)
    server.mount_proc(path) do |request, response|
      yield request, response
    end
  end

  def start
    Thread.fork { server.start }
  end
end

server = WebServer.new
server.page("/simple_get", "simple_html.erb")
server.page("/second_page", "second_page.erb")
server.page("/nested_path/index.html", "nested_path.erb")
server.page("/nested_path/nested_in.html", "nested_path.erb")
server.page("/form", "form.erb")
server.page("/form_without_method", "form_without_method.erb")
server.page("/scoped_links", "scoped_links.erb")
server.page("/doit", "doit.erb")
server.page("/scoped_links", "scoped_links.erb")
server.page("/form_header", "form_header.erb")
server.page("/request_headers", "request_headers.erb")
server.page("/cookies", "cookies.erb")
server.page("/500", "simple_html.erb") { |_, response| response.status = 500 }
server.page("/unknown_encoding") { |_, response| response["content-encoding"] = "nopez" }
server.page("/gzipped_page", "gzipped_response.html.gz") { |_, response| response["content-encoding"] = "gzip" }
server.page("/set_cookie") do |req, resp|
  req.query.each do |k, v|
    v.each_data do |d|
      resp.cookies << "#{k}=#{d}"
    end
  end
end
server.redirect("/infinite_redirect", "/infinite_redirect")
server.redirect("/single_redirect", "/simple_get")

server.start
