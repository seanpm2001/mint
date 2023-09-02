module Mint
  class Parser
    def block(&)
      parse(track: false) do
        whitespace
        next unless char! '{'
        whitespace

        result = yield
        whitespace

        next unless char! '}'
        result
      end
    end
  end
end
