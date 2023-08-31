module Mint
  class Parser
    def html_element : Ast::HtmlElement?
      parse do |start_position|
        tag = parse(track: false) do
          next unless char! '<'
          next unless value = variable track: false, extra_chars: ['-']
          value
        end

        next unless tag

        styles = [] of Ast::HtmlStyle

        if keyword_ahead? "::"
          styles = many(parse_whitespace: false) { html_style }

          next error :html_element_expected_style do
            expected "the style for an HTML element", word
            snippet self
          end if styles.empty?
        end

        whitespace
        if keyword "as"
          whitespace
          next error :html_element_expected_reference do
            expected "the reference of an HTML element", word
            snippet self
          end unless ref = variable
        end

        attributes, children, comments, closing_tag_position =
          html_body(
            with_dashes: true,
            tag: tag,
            expected_closing_bracket: ->{
              error :html_component_expected_closing_bracket do
                expected "the closing bracket of an HTML element", word
                snippet self
              end
            },
            expected_closing_tag: ->{
              error :html_component_expected_closing_tag do
                expected "the closing tag of an HTML element", word
                snippet self
              end
            })

        Ast::HtmlElement.new(
          closing_tag_position: closing_tag_position,
          attributes: attributes,
          from: start_position,
          children: children,
          comments: comments,
          styles: styles,
          to: position,
          input: data,
          tag: tag,
          ref: ref)
      end
    end
  end
end
