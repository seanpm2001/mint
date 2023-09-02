module Mint
  class Parser
    def style : Ast::Style?
      parse do |start_position|
        next unless word! "style"

        whitespace
        next error :style_expected_name do
          expected "the name of a style", word
          snippet self
        end unless name = variable extra_chars: ['-']
        whitespace

        arguments = [] of Ast::Argument

        if char! '('
          whitespace
          arguments = list(terminator: ')', separator: ',') { argument }
          whitespace

          next error :style_expected_closing_parenthesis do
            expected "the closing parenthesis of a style", word
            snippet self
          end unless char! ')'
        end

        body = block2(
          ->{ error :style_expected_opening_bracket do
            expected "the opening bracket of a style", word
            snippet self
          end },
          ->{ error :style_expected_closing_bracket do
            expected "the closing bracket of a style", word
            snippet self
          end }
        ) do
          items = many { css_keyframes || css_font_face || css_node }

          error :style_expected_body do
            expected "the body of a style", word
            snippet self
          end if items.empty?

          items
        end

        Ast::Style.new(
          from: start_position,
          arguments: arguments,
          to: position,
          file: file,
          body: body,
          name: name)
      end
    end

    def css_node
      comment ||
        case_expression(for_css: true) ||
        if_expression(for_css: true) ||
        css_nested_at ||
        css_definition_or_selector
    end

    def css_body
      many { css_node }
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
