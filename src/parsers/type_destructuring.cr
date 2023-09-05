module Mint
  class Parser
    def type_destructuring
      parse do |start_position|
        next unless name = id track: false
        next unless word! "::"

        next error :type_destructuring_expected_option do
          expected "the type of an type destructuring", word
          snippet self
        end unless variant = id

        items = [] of Ast::Node

        if char! '('
          whitespace
          items.concat list(
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
          from: start_position,
          variant: variant,
          items: items,
          to: position,
          file: file,
          name: name)
      end
    end
  end
end
