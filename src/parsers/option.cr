module Mint
  class Parser
    def option
      parse do |start_position|
        next unless name = type_id

        Ast::Option.new(
          from: start_position,
          to: position,
          file: file,
          name: name)
      end
    end
  end
end
