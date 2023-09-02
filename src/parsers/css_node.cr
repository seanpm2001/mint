module Mint
  class Parser
    def css_node
      comment ||
        case_expression(for_css: true) ||
        if_expression(for_css: true) ||
        css_nested_at ||
        css_definition_or_selector
    end
  end
end
