module Mint
  class Ast
    module Directives
      class Inline < Node
        getter real_path : Path
        getter path

        def initialize(@path : String,
                       @file : Parser::File,
                       @from : Int64,
                       @to : Int64)
          @real_path = Path[file.path].sibling(path).expand
        end

        def exists?
          File.exists?(real_path)
        end

        def file_contents : String
          File.read(real_path)
        end
      end
    end
  end
end
