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
    mount_text("", "favicon.ico")
  end

  def layout(name)
    if name == false
      ERB.new("<%= @content %>")
    else
      ERB.new(File.read(File.join("test", "server", "layouts", name)))
    end
  end

  def erb?(path)
    File.exist?(path) and path[-3 .. -1] == "erb"
  end

  def file?(path)
    File.exist?(path)
  end

  #def page(path, content = nil, opts = {})
  def mount(data, path = nil, opts = {})
    if erb?(data) # parse and mount erb file
      mount_erb(data, path, opts)
    elsif file?(data) # mount file contents
      mount_file(data, path, opts)
    else # mount as simple text
      mount_text(data, path, opts)
    end
  end

  def redirect(from, to, permanent = false)
    mount_text("You are being <a href=\"%s\">redirected</a>..." % [to], from) do |request, response|
      response.status = permanent ? 301 : 302
      response["Location"] = to
    end
  end

  def mount_erb(file, path = nil, opts = {})
    layout_name = opts[:layout] == false ? "layout.html.erb" : opts[:layout] || "layout.html.erb"
    layout = layout(layout_name)
    path ||= file.split(File::SEPARATOR)[3 .. -1].join(File::SEPARATOR)[0 .. -5]
    path = "/%s" % [path] unless path[0, 1] == "/"
    STDOUT.puts "Mounting ERB '%s' in '%s'" % [file, path]
    server.mount_proc(path) do |request, response|
      @request, @response = request, response
      yield request, response if block_given?
      erb = ERB.new(File.read(file))
      @content = erb.result(binding)
      response.body = layout.result(binding)
    end
  end

  def mount_file(file, path = nil, opts = {})
    layout_name = opts[:layout] == false ? "layout.html.erb" : opts[:layout] || "layout.html.erb"
    layout = layout(layout_name)
    path ||= file.split(File::SEPARATOR)[3 .. -1].join(File::SEPARATOR)
    path = "/%s" % [path] unless path[0, 1] == "/"
    STDOUT.puts "Mounting file '%s' in '%s'" % [file, path]
    server.mount_proc(path) do |request, response|
      @request, @response = request, response
      yield request, response if block_given?
      text = File.read(file)
      @content = text
      response.body = layout.result(binding)
    end
  end

  def mount_text(text, path, opts = {})
    layout_name = opts[:layout] == false ? "layout.html.erb" : opts[:layout] || "layout.html.erb"
    layout = layout(layout_name)
    path = "/%s" % [path] unless path[0, 1] == "/"
    STDOUT.puts "Mounting text in '%s'" % [path]
    server.mount_proc(path) do |request, response|
      @request, @response = request, response
      yield request, response if block_given?
      @content = text
      response.body = layout.result(binding)
    end
  end

  def automount(path = "")
    path = File.join("test", "server", "root", path)
    files = Dir[File.join(path, "**", "*.*")]
    files.each do |file|
      mount(file)
    end
  end

  def start
    Thread.fork { server.start }
  end
end

server = WebServer.new
server.automount
server.mount_text("500 error", "/500") { |_, response| response.status = 500 }
server.mount_text("enc", "/unknown_encoding") { |_, response| response["content-encoding"] = "nopez" }
server.mount_text("", "/set_cookie") do |req, resp|
  req.query.each do |k, v|
    v.each_data do |d|
      resp.cookies << "#{k}=#{d}"
    end
  end
end
server.redirect("/infinite_redirect", "/infinite_redirect")
server.redirect("/single_redirect", "/simple_html.html")

server.start
