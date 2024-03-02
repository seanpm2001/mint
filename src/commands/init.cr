module Mint
  class Cli < Admiral::Command
    class Init < Admiral::Command
      include Command

      define_help description: "Initializes a new project"

      define_flag bare : Bool,
        description: "If speficied an empty project will be generated",
        default: false

      define_argument name,
        description: "The name of the new project",
        required: false

      def run
        execute "Initializing a new project" do
          name = arguments.name.presence

          while name.nil?
            terminal.puts "Please provide a name for the project (for example my-project):"
            name = gets.presence
          end

          Scaffold.new(name: name, bare: flags.bare)
        end
      end
    end
  end
end
