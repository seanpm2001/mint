module Mint
  class Cli < Admiral::Command
    class Build < Admiral::Command
      include Command

      define_help description: "Builds the project for production"

      define_flag relative : Bool,
        description: "If specified the URLs in the index.html will be in relative format",
        default: false,
        short: "r"

      define_flag generate_manifest : Bool,
        description: "If specified the web manifest will be generated",
        default: false

      define_flag skip_icons : Bool,
        description: "If specified the application icons will not be generated",
        default: false

      define_flag minify : Bool,
        description: "If specified the resulting JavaScript code will be minified",
        default: true,
        short: "m"

      define_flag runtime : String,
        description: "Will use supplied runtime path instead of the default distribution",
        required: false

      define_flag watch : Bool,
        description: "Enables watch mode for build",
        default: false,
        short: "w"

      def run
        execute "Building for production..." do
          # Initialize the workspace from the current working directory. We don't
          # check everything to speed things up so only the hot path is checked.
          workspace = Workspace.current
          workspace.check_everything = false
          workspace.check_env = true

          # Check if we have dependencies installed.
          workspace.json.check_dependencies!

          # On any change we copy the build to the dist directory.
          workspace.on("change") do |result|
            terminal.reset if flags.watch

            case result
            in Ast
              terminal.puts "Building for production..."
              terminal.divider

              terminal.measure "#{COG} Clearing the \"#{DIST_DIR}\" directory..." do
                FileUtils.rm_rf DIST_DIR
              end

              files =
                Bundler.new(
                  artifacts: workspace.type_checker.artifacts,
                  json: workspace.json,
                  config: Bundler::Config.new(
                    generate_manifest: flags.generate_manifest,
                    skip_icons: flags.skip_icons,
                    runtime_path: flags.runtime,
                    relative: flags.relative,
                    optimize: flags.minify,
                    include_program: true,
                    live_reload: false,
                    hash_assets: true,
                    test: nil)).bundle

              files
                .keys
                .sort_by!(&.size)
                .reverse!
                .each do |path|
                  terminal.measure "#{COG} Writing #{path.lchop('/')}..." do
                    noramlized_path =
                      Path[DIST_DIR, path.lchop('/')]

                    FileUtils.mkdir_p(noramlized_path.dirname)
                    File.write(noramlized_path, files[path].call)
                  end
                end
            in Error
              terminal.print result.to_terminal
            end
          end

          # Do the initial parsing and type checking.
          workspace.update_cache

          # Start wathing for changes if the flag is set.
          if flags.watch
            workspace.watch
            sleep
          end
        end
      end
    end
  end
end
