module Mint
  class Parser
    def enum_id_expressions
      expressions = [] of Ast::Expression

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
        return unless char! ')'
      end

      expressions
    end

    def enum_id
      parse do |start_position|
        next unless option = type_id track: false

        if keyword "::"
          name = option
          next error :enum_id_expected_option do
            expected "the option of an enum id", word
            snippet self
          end unless option = type_id track: false
        end

        if name ||
           (option.value[0].ascii_uppercase? && !option.value.chars.all? { |char| char == '_' || char.ascii_uppercase? })
          self << Ast::EnumId.new(
            expressions: enum_id_expressions || [] of Ast::Expression,
            from: start_position,
            option: option,
            to: position,
            input: data,
            name: name)
        else
          self << Ast::Variable.new(
            from: start_position,
            value: option.value,
            to: position,
            input: data)
        end
      end
    end
  end
end
