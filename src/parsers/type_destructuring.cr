module Mint
  class Parser
    def type_destructuring
      parse do |start_position|
        next unless name = type_id track: false
        next unless word! "::"

        next error :type_destructuring_expected_option do
          expected "the type of an type destructuring", word
          snippet self
        end unless option = type_id

        parameters = [] of Ast::Node

        if char! '('
          whitespace
          parameters.concat list(
            terminator: ')',
            separator: ','
          ) { destructuring }
          whitespace

          next error :type_destructuring_expected_closing_parenthesis do
            expected "the closing parenthesis of an type destructuring", word
            snippet self
          end unless char! ')'
        end

        Ast::TypeDestructuring.new(
          parameters: parameters,
          from: start_position,
          option: option,
          to: position,
          file: file,
          name: name)
      end
    end
  end
end
