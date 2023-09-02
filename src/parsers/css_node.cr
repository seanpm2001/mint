module Mint
  class Parser
    def css_node
      comment ||
        case_expression(for_css: true) ||
        if_expression(for_css: true) ||
        css_nested_at ||
        css_definition_or_selector
    end

    def css_definition_or_selector
      parse(track: false) do |_, _, error_position|
        node = css_definition || css_selector

        if error_position < @errors.size
          if (error = @errors[error_position]) && node
            if error.name == :css_definition_expected_semicolon
              @errors.delete(error)
            end
          end
        end

        node
      end
    end
  end
end
