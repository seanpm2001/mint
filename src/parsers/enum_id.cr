module Mint
  class Parser
    def enum_id
      parse do |start_position|
        next unless name = type_id track: false
        next unless word! "::"

        next error :enum_id_expected_option do
          expected "the option of an enum id", word
          snippet self
        end unless option = type_id track: false

        expressions = [] of Ast::Node

        if char! '('
          whitespace

          item = enum_record

          if item
            expressions << item
          else
            expressions.concat list(
              terminator: ')',
              separator: ','
            ) { expression }
          end

          whitespace
          next error :enum_id_expected_closing_parenthesis do
            expected "the closing parenthesis of an enum id", word
            snippet self
          end unless char! ')'
        end

        Ast::EnumId.new(
          expressions: expressions,
          from: start_position,
          option: option,
          to: position,
          file: file,
          name: name)
      end
    end
  end
end
