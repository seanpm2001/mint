module Mint
  class Parser
    def option
      parse do |start_position|
        next unless name = type_id

        Ast::Option.new(
          from: start_position,
          to: position,
          input: data,
          name: name)
      end
    end
  end
end
