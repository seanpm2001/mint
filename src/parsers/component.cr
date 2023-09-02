module Mint
  class Parser
    def component : Ast::Component?
      parse do |start_position, start_nodes_position|
        comment = self.comment

        global = word! "global"
        whitespace

        next unless word! "component"
        whitespace

        next error :component_expected_name do
          expected "name of the component", word

          block do
            text "The name of a component must start with an uppercase letter"
            text "and only contain lowercase, uppercase letters and numbers."
          end

          snippet self
        end unless name = type_id
        whitespace

        body = brackets(
          ->{ error :component_expected_opening_bracket do
            expected "the opening bracket of the component", word
            snippet self
          end },
          ->{ error :component_expected_closing_bracket do
            expected "the closing bracket of the component", word
            snippet self
          end }
        ) do
          many do
            property ||
              connect ||
              constant ||
              function ||
              style ||
              state ||
              use ||
              get ||
              self.comment
          end.tap do |items|
            next error :component_expected_body do
              expected "the body of a component", word
              snippet self
            end if items.reject(Ast::Comment).empty?
          end
        end

        next unless body

        properties = [] of Ast::Property
        functions = [] of Ast::Function
        constants = [] of Ast::Constant
        connects = [] of Ast::Connect
        comments = [] of Ast::Comment
        styles = [] of Ast::Style
        states = [] of Ast::State
        gets = [] of Ast::Get
        uses = [] of Ast::Use

        body.each do |item|
          case item
          when Ast::Property
            properties << item
          when Ast::Function
            functions << item

            item.keep_name = true if item.name.value == "render"
          when Ast::Constant
            constants << item
          when Ast::Connect
            connects << item
          when Ast::Comment
            comments << item
          when Ast::Style
            styles << item
          when Ast::State
            states << item
          when Ast::Get
            gets << item
          when Ast::Use
            uses << item
          end
        end

        refs = [] of Tuple(Ast::Variable, Ast::Node)

        ast.nodes[start_nodes_position...].each do |node|
          case node
          when Ast::HtmlElement
            node.styles.each do |style|
              style.style_node =
                styles.find(&.name.value.==(style.name.value))
            end
          end

          case node
          when Ast::HtmlComponent,
               Ast::HtmlElement
            if ref = node.ref
              refs << {ref, node.as(Ast::Node)}
            end
            node.in_component = true
          end
        end

        Ast::Component.new(
          locales: ast.nodes[start_nodes_position...].any?(Ast::LocaleKey),
          global: global || false,
          properties: properties,
          functions: functions,
          constants: constants,
          from: start_position,
          connects: connects,
          comments: comments,
          comment: comment,
          styles: styles,
          states: states,
          to: position,
          file: file,
          refs: refs,
          name: name,
          uses: uses,
          gets: gets).tap do |node|
          ast.nodes[start_nodes_position...]
            .select(Ast::NextCall)
            .each(&.entity=(node))
        end
      end
    end
  end
end
