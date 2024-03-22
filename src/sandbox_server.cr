module Mint
  class SandboxServer
    # Represents a source file.
    struct File
      include JSON::Serializable

      getter contents : String
      getter path : String

      def initialize(@contents, @path)
      end
    end

    # Represents a project.
    struct Project
      include JSON::Serializable

      getter files : Array(File)
      getter? id : String?

      def initialize(@files)
      end
    end

    # A handler for allowing cross origin requests.
    class CORS
      include HTTP::Handler

      def call(context)
        context.response.headers["Access-Control-Max-Age"] = 1.day.total_seconds.to_i.to_s
        context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH"
        context.response.headers["Access-Control-Allow-Headers"] = "Content-Type"
        context.response.headers["Access-Control-Allow-Credentials"] = "true"
        context.response.headers["Access-Control-Allow-Origin"] = "*"

        if context.request.method.upcase == "OPTIONS"
          context.response.content_type = "text/html; charset=utf-8"
          context.response.status = :ok
        else
          call_next context
        end
      end
    end

    def initialize(@host = "0.0.0.0", @port = ENV["PORT"]?.try(&.to_i) || 8080, runtime_path : String? = nil)
      @server = HTTP::Server.new([CORS.new]) do |context|
        handle_request(context)
      end
      @formatter = Formatter.new
      @core = Core.ast
    end

    def handle_request(context)
      json =
        Project.from_json(context.request.body.try(&.gets_to_end).to_s)

      case context.request.path
      when "/compile"
        Dir.tempdir do
          json.files.each do |file|
            ::File.write(file.path, file.contents)
          end

          ::File.write("mint.json", {
            "source-directories" => ["."],
          }.to_json)

          workspace = Workspace.current
          workspace.update_cache

          bundle =
            if error = workspace.error
              {"index.html" => ->{ error.to_html }}
            else
              Bundler.new(
                artifacts: workspace.type_checker.artifacts,
                json: workspace.json,
                config: Bundler::Config.new(
                  generate_manifest: false,
                  include_program: true,
                  hash_assets: false,
                  runtime_path: nil,
                  live_reload: false,
                  skip_icons: false,
                  relative: false,
                  optimize: true,
                  test: nil),
              ).bundle
            end

          io =
            IO::Memory.new

          Compress::Zip::Writer.open(io) do |zip|
            bundle.each do |path, contents|
              zip.add(path, contents.call)
            end
          end

          io.rewind
          HTTP::Client.post("https://#{json.id?}.sandbox.mint-lang.com/", body: io)
        end

        context.response.content_type = "application/json"
        context.response.print({
          "url" => "https://#{json.id?}.sandbox.mint-lang.com/",
        }.to_json)
      when "/format"
        formatted_files =
          json.files.map do |file|
            ast =
              Parser.parse(file.contents, file.path)

            formatted =
              @formatter.format(ast)

            File.new(contents: formatted, path: file.path)
          end

        context.response.content_type = "application/json; charset=utf-8"
        context.response.print({
          "files" => formatted_files,
        }.to_json)
      end
    end

    def start
      address =
        @server.bind_tcp @host, @port

      puts "Listening on http://#{address}"
      @server.listen
    end
  end
end
