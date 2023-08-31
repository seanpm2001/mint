module Mint
  class Parser
    def array_access(lhs : Ast::Expression) : Ast::ArrayAccess?
      parse do |start_position|
        next unless char! '['
        whitespace

        index =
          gather { chars &.ascii_number? }.to_s

        index =
          if index.empty?
            next error :array_access_expected_index do
              expected "the index into the array", word
              snippet self
            end unless item = expression

            item
          else
            index.to_i64
          end

        whitespace
        next error :array_access_expected_closing_bracket do
          expected "the closing bracket of the array", word
          snippet self
        end unless char! ']'

        Ast::ArrayAccess.new(
          from: start_position,
          to: position,
          index: index,
          input: data,
          lhs: lhs)
      end
    end
  end
end
