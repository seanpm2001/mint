module Mint
  class Ast
    module Directives
      class Asset < Node
        getter real_path : Path
        getter path

        def initialize(
          @file : Parser::File,
          @path : String,
          @from : Int64,
          @to : Int64
        )
          @real_path = Path[file.path].sibling(path).expand
        end

        def filename(build) : String?
          return unless exists?

          hash_base =
            build ? file_contents : real_path.to_s

          hash =
            Digest::MD5.new
              .update(hash_base)
              .final
              .hexstring

          "#{real_path.stem}_#{hash}#{real_path.extension}"
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
