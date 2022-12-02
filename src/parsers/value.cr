module Mint
  class Parser
    def value : Ast::Value?
      start do |start_position|
        name =
          type_id ||
            gather { letters_numbers_or_underscore }

        next unless name

        self << Ast::Value.new(
          from: start_position,
          to: position,
          input: data,
          name: name)
      end
    end
  end
end
