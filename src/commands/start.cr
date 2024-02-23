module Mint
  class Cli < Admiral::Command
    class Start < Admiral::Command
      include Command

      define_help description: "Starts the development server"

      define_flag format : Bool,
        description: "Formats the source files when they change.",
        required: false,
        default: false

      define_flag host : String,
        description: "The host to serve the application on.",
        default: ENV["HOST"]? || "127.0.0.1",
        required: false,
        short: "h"

      define_flag port : Int32,
        description: "The port to serve the application on.",
        default: (ENV["PORT"]? || "3000").to_i,
        required: false,
        short: "p"

      define_flag reload : Bool,
        description: "Reload the browser when something changes.",
        required: false,
        default: true,
        short: "r"

      def run
        execute "Running the development server" do
          Reactor.new(
            format: flags.format,
            reload: flags.reload,
            host: flags.host,
            port: flags.port)
        end
      end
    end
  end
end
