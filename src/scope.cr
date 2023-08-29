module Mint
  class Scope
    record Level, node : Ast::Node | Nil, items : Item = Item.new
    record Target, node : Ast::Node, parent : Ast::Node

    alias Item = Hash(String, Target)
    getter ast

    getter node_scope : Hash(Ast::Node, Level) = {} of Ast::Node => Level
    getter scopes : Hash(Ast::Node, Array(Level)) = {} of Ast::Node => Array(Level)
    getter pending : Array(Ast::Variable) = [] of Ast::Variable

    def initialize(@ast : Ast)
      @ast.unified_modules.each { |item| build(item) }
      @ast.components.each { |item| build(item) }
      @ast.providers.each { |item| build(item) }
      @ast.locales.each { |item| build(item) }
      @ast.suites.each { |item| build(item) }
      @ast.stores.each { |item| build(item) }

      # debug
      # puts "----------"
      resolve
    end

    def add(node : Ast::Node, key : String, value : Ast::Node)
      @node_scope[node].items[key] = Target.new(value, node)
    end

    def resolve(node : Ast::Variable)
      case stack = @scopes[node]?
      when Array(Level)
        stack.reverse_each do |level|
          level.items.each do |key, value|
            return value if key == node.value
          end
        end
      end
    end

    def resolve
      scopes.select { |node, _| node.is_a?(Ast::Component) }.each do |node, stack|
        case node
        when Ast::Component
          node.connects.each do |connect|
            case store = ast.stores.find(&.name.value.==(connect.store.value))
            in Ast::Store
              connect.keys.each do |key|
                @scopes[store][1].items[key.variable.value]?.try do |value|
                  stack[1].items[key.name.try(&.value) || key.variable.value] = value
                end
              end
            in Nil
            end
          end
        end
      end

      #      puts "Resolving scope..."
      # flattened =
      #   scopes.select { |node, _| node.is_a?(Ast::Variable) }.map do |node, stack|
      #     result = {} of String => Target

      #     stack.each do |level|
      #       level.items.each do |key, value|
      #         # raise "WTF" if result[key]?
      #         result[key] = value
      #       end
      #     end

      #     {node, result}
      #   end.to_h

      # flattened.each do |node, map|
      #   if node.input.file == "/Provider/Intersection.mint"
      #     puts debug_name(node)

      #     # scopes[node].each_with_index do |item, index|
      #     #   puts debug_name(item.node).indent(index * 2)
      #     # end

      #     map.each do |key, node|
      #       puts "  #{key}: #{debug_name(node)}"
      #     end
      #   end
      # end

      # pending.map do |node|
      #   # resolved[node] = flattened[node][node.value]?
      #   # puts debug_name(node)
      #   # puts " -> #{debug_name(resolved[node])}"
      # end
    end

    def debug_name(node)
      case node
      when Target
        "{#{debug_name(node.node)}, #{debug_name(node.parent)}}"
      when Tuple(Ast::Node, Ast::Node)
        "{#{debug_name(node[0])}, #{debug_name(node[1])}}"
      else
        suffix =
          case node
          when Ast::Component
            node.name.value
          when Ast::Function
            node.name.value
          when Ast::Argument
            node.name.value
          when Ast::Variable
            node.value
          end

        prefix =
          if suffix
            "#{node.class.name}(#{suffix})"
          else
            node.class.name
          end

        "#{prefix}#{node.try(&.location.start)}"
      end
    end

    def debug
      scopes.each do |node, stack|
        puts debug_name(node)
        stack.each_with_index do |item, index|
          puts "#{" " * ((index + 1) * 2)}#{debug_name(item.node)}"
          item.items.each do |key, value|
            puts "#{" " * ((index + 2) * 2)}#{key} -> #{value.class.name}"
          end
        end
      end
    end

    def build(node, parent = nil)
      scopes[node] =
        if parent
          scopes[parent].dup
        else
          [Level.new(parent)]
        end

      level = Level.new(node)
      node_scope[node] = level
      scopes[node] << level

      if scope = scopes[parent]?.try(&.last?)
        yield scope
      else
        yield Level.new(nil)
      end
    end

    def build(node : Ast::Component)
      build(node) do
        build(node.properties, node)
        build(node.functions, node)
        build(node.constants, node)
        build(node.states, node)
        build(node.styles, node)
        build(node.gets, node)
        build(node.uses, node)
      end
    end

    def build(node : Ast::Locale)
      build(node) do
        build(node.fields, node)
      end
    end

    def build(node : Ast::Store)
      build(node) do
        build(node.functions, node)
        build(node.constants, node)
        build(node.states, node)
        build(node.gets, node)
      end
    end

    def build(node : Ast::Module)
      build(node) do
        build(node.constants, node)
        build(node.functions, node)
      end
    end

    def build(node : Ast::Suite)
      build(node) do
        build(node.constants, node)
        build(node.tests, node)
      end
    end

    def build(node : Ast::Provider)
      build(node) do
        scopes[node][1].items["subscriptions"] = Target.new(node, node)
        build(node.functions, node)
        build(node.constants, node)
        build(node.states, node)
        build(node.gets, node)
      end
    end

    def build(node : Ast::Test, parent : Ast::Node)
      build(node, parent) do
        build(node.expression, node)
      end
    end

    def build(node : Ast::State, parent : Ast::Node)
      build(node, parent) do |scope|
        scope.items[node.name.value] = Target.new(node, parent)

        build(node.default, node)
      end
    end

    def build(node : Ast::Property, parent : Ast::Node)
      build(node, parent) do |scope|
        scope.items[node.name.value] = Target.new(node, parent)

        build(node.default, node)
      end
    end

    def build(node : Ast::Function, parent : Ast::Node)
      build(node, parent) do |scope|
        scope.items[node.name.value] = Target.new(node, parent)

        build(node.arguments, node)
        build(node.body, node)
      end
    end

    def build(node : Ast::Style, parent : Ast::Node)
      build(node, parent) do |scope|
        scope.items[":style_#{node.name.value}"] = Target.new(node, parent)

        build(node.arguments, node)
        build(node.body, node)
      end
    end

    def build(node : Ast::CssDefinition, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.value.select(Ast::Node), node)
      end
    end

    def build(node : Ast::CssFontFace, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.definitions, node)
      end
    end

    def build(node : Ast::CssSelector, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.body, node)
      end
    end

    def build(node : Ast::CssNestedAt, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.body, node)
      end
    end

    def build(node : Ast::CssKeyframes, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.selectors, node)
      end
    end

    def build(node : Ast::Get, parent : Ast::Node)
      build(node, parent) do |scope|
        scope.items[node.name.value] = Target.new(node, parent)

        build(node.body, node)
      end
    end

    def build(node : Ast::EnumId, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.expressions, node)
      end
    end

    def build(node : Ast::If, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.branches[0], node)
        build(node.branches[1], node)
        build(node.condition, node)
      end
    end

    def build(node : Ast::Case, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.condition, node)
        build(node.branches, node)
      end
    end

    def build(node : Ast::For, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.condition, node)
        build(node.subject, node)
        build(node.body, node)
      end
    end

    def build(node : Ast::Constant, parent : Ast::Node)
      build(node, parent) do |scope|
        scope.items[node.name.value] = Target.new(node, parent)

        build(node.value, node)
      end
    end

    def build(node : Ast::HtmlStyle, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.arguments, node)
        build(node.name, node)
      end
    end

    def build(node : Ast::InlineFunction, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.arguments, node)
        build(node.body, node)
      end
    end

    def build(node : Ast::Argument, parent : Ast::Node)
      build(node, parent) do |scope|
        scope.items[node.name.value] = Target.new(node, parent)
      end
    end

    def build(node : Ast::Block, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.statements, node, stack: true)
      end
    end

    def build(node : Ast::Operation, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.left, node)
        build(node.right, node)
      end
    end

    def build(node : Ast::Access, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.expression, node)
      end
    end

    def build(node : Ast::Pipe, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.expression, node)
        build(node.argument, node)
      end
    end

    def build(node : Ast::ReturnCall, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.expression, node)
      end
    end

    def build(node : Ast::HtmlExpression, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.expressions, node)
      end
    end

    def build(node : Ast::HtmlFragment, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.children, node)
        build(node.key, node)
      end
    end

    def build(node : Ast::HtmlAttribute, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.value, node)
      end
    end

    def build(node : Ast::ArrayAccess, parent : Ast::Node)
      build(node, parent) do |scope|
        case node.index
        when Ast::Node
          build(node.index.as(Ast::Node), node)
        end

        build(node.lhs, node)
      end
    end

    def build(node : Ast::Use, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.condition, node)
        build(node.data, node)
      end
    end

    def build(node : Ast::Record, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.fields, node)
      end
    end

    def build(node : Ast::NextCall, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.data, node)
      end
    end

    def build(node : Ast::RecordUpdate, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.expression, node)
        build(node.fields, node)
      end
    end

    def build(node : Ast::RecordField, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.value, node)

        case parent
        when Ast::Record
          build(node.key, node)
        end
      end
    end

    def build(node : Ast::Variable, parent : Ast::Node)
      build(node, parent) do |scope|
        pending << node
      end
    end

    def build(node : Ast::HtmlElement, parent : Ast::Node)
      build(node, parent) do |scope|
        if (ref = node.ref) && (root = scopes[parent][1].node).is_a?(Ast::Component)
          scopes[parent][1].items[ref.value] = Target.new(node, root)
        end

        build(node.attributes, node)
        build(node.children, node)
        build(node.styles, node)
      end
    end

    def build(node : Ast::HtmlComponent, parent : Ast::Node)
      build(node, parent) do |scope|
        if (ref = node.ref) && (root = scopes[parent][1].node).is_a?(Ast::Component)
          case x = ast.components.find(&.name.value.==(node.component.value))
          when Ast::Component
            scopes[parent][1].items[ref.value] = Target.new(node, x)
          end
        end

        build(node.attributes, node)
        build(node.children, node)
      end
    end

    def build(node : Ast::ArrayLiteral, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.items, node)
      end
    end

    def build(node : Ast::TupleLiteral, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.items, node)
      end
    end

    def build(node : Ast::Call, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.arguments, node)
        build(node.expression, node)
      end
    end

    def build(node : Ast::CallExpression, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.expression, node)
      end
    end

    def build(node : Ast::Directives::Format, parent : Ast::Node)
      build(node, parent) do |scope|
        build(node.content, node)
      end
    end

    def build(nodes : Array(Ast::Node), parent : Ast::Node, *, stack : Bool = false)
      if stack
        nodes.reduce(parent) do |memo, item|
          next memo if item.is_a?(Ast::Comment)
          build(item, memo)
          item
        end
      else
        nodes.each { |item| build(item, parent) }
      end
    end

    def build(node : Ast::Node, parent : Ast::Node?)
      case node
      when Ast::NumberLiteral,
           Ast::BoolLiteral,
           Ast::ModuleAccess,
           Ast::LocaleKey,
           Ast::ArrayDestructuring,
           Ast::TupleDestructuring,
           Ast::EnumDestructuring,
           Ast::Env,
           Ast::Void,
           Ast::Directives::Documentation,
           Ast::Directives::Inline,
           Ast::Directives::Asset,
           Ast::Directives::Svg,
           Ast::MemberAccess,
           Ast::Comment,
           Ast::RegexpLiteral
      when Ast::StringLiteral,
           Ast::HereDoc,
           Ast::Js
        build(node, parent) do |scope|
          build(node.value.select(Ast::Interpolation), node)
        end
      when Ast::UnaryMinus,
           Ast::NegatedExpression,
           Ast::ParenthesizedExpression,
           Ast::Interpolation,
           Ast::Encode,
           Ast::CaseBranch,
           Ast::Decode
        build(node, parent) do |scope|
          build(node.expression, node)
        end
      when Ast::Statement
        build(node, parent) do |scope|
          build(node.expression, node)

          case target = node.target
          when Ast::Variable
          else
            build(node.target, node)
          end
        end
      else
        raise "SCOPE!!!: #{node.class.name}"
      end
    end

    def build(node : Nil, parent : Ast::Node?)
    end
  end
end
