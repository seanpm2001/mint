module Mint
  class Parser
    def type_destructuring : Ast::TypeDestructuring?
      parse do |start_position|
        next unless name = id track: false

        # TODO: Remove this branch in 0.21.0 when deprecation ends.
        if word! "::"
          next error :type_destructuring_expected_variant do
            expected "the type of an type destructuring", word
            snippet self
          end unless variant = id(track: false)
        else
          parts = name.value.split('.')

          next error :type_destructuring_expected_variant do
            expected "the type of an type destructuring", word
            snippet self
          end if parts.size == 0

          variant_name =
            parts.pop

          parent_name =
            parts.join('.')

          parent_to =
            start_position + parent_name.size

          name =
            Ast::Id.new(
              from: start_position,
              value: parent_name,
              to: parent_to,
              file: file)

          variant =
            Ast::Id.new(
              to: parent_to + 1 + variant_name.size,
              value: variant_name,
              from: parent_to,
              file: file)
        end

        ast.nodes << variant
        ast.nodes << name

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
