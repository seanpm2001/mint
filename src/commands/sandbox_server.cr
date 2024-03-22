module Mint
  class Cli < Admiral::Command
    class SandboxServer < Admiral::Command
      define_help description: "Server for compiling sandbox applications."

      define_flag host : String,
        description: "The host the server binds to.",
        default: ENV["HOST"]? || "0.0.0.0",
        short: "h"

      define_flag port : Int32,
        description: "The port the server binds to.",
        default: (ENV["PORT"]? || "3003").to_i,
        short: "p"

      def run
        server = Mint::SandboxServer.new(flags.host, flags.port)
        server.start
      end
    end
  end
end
