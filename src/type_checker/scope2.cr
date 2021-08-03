module Mint
  class TypeChecker
    class Scope2
      # Represents a mapping of variable names to AST nodes.
      alias Map = Hash(String, Ast::Node)

      # We store the map of each node in a cache for performance.
      @cache = {} of Ast::Node => Map

      # Represents the current scope, recent levels at the front.
      @stack = [] of Tuple(Map, Ast::Node)

      def initialize(@ast : Ast)
      end

      def push(node : Ast::Node)
        push([node]) { yield }
      end

      def push(nodes : Array(Ast::Node))
        items =
          nodes.map { |node| @cache.fetch(node) { {resolve(node), node} } }

        items.each { |item| @stack.unshift item }

        begin
          yield
        ensure
          items.each { |item| @stack.delete item }
        end
      end

      def only(nodes : Array(Ast::Node))
        saved = @stack

        begin
          push(nodes) { yield }
        ensure
          @stack = saved
        end
      end

      def with(node : Ast::Node)
        case node
        when Ast::Component,
             Ast::Provider,
             Ast::Module,
             Ast::Store
          only([node]) { yield }
        when Ast::Function,
             Ast::Get
          only([node, node.parent]) { yield }
        else
          push(node) { yield }
        end
      end

      def find(variable : String) : Ast::Node?
        @stack.each do |(key, node)|
          return node if key == variable
        end
      end

      def resolve(node : Ast::Node, map : Map = Map.new)
        raise "Cannot resolve scope for: #{node.class}"
      end

      def resolve(node : Ast::InlineFunction, map : Map = Map.new) : Map
        resolve(node.arguments, map)
      end

      def resolve(node : Ast::Function, map : Map = Map.new) : Map
        node.where.try { |where| resolve(where, map) }
        resolve(node.arguments, map)
      end

      def resolve(node : Ast::Where, map : Map = Map.new) : Map
        resolve(node.statements, map)
      end

      def resolve(node : Ast::Style, map : Map = Map.new) : Map
        resolve(node.arguments, map)
      end

      def resolve(node : Ast::Module, map : Map = Map.new) : Map
        resolve(node.functions, map)
        resolve(node.constants, map)
      end

      def resolve(node : Ast::Suite, map : Map = Map.new) : Map
        resolve(node.constants, map)
      end

      def resolve(node : Ast::Store, map : Map = Map.new) : Map
        resolve(node.functions, map)
        resolve(node.constants, map)
        resolve(node.states, map)
        resolve(node.gets, map)
      end

      def resolve(node : Ast::Provider, map : Map = Map.new) : Map
        @ast.records.find(&.name.==(node.name)).try do |subscription|
          map["subscriptions"] = subscription
        end

        resolve(node.functions, map)
        resolve(node.constants, map)
        resolve(node.states, map)
        resolve(node.gets, map)
      end

      def resolve(node : Ast::Component, map : Map = Map.new) : Map
        # Resolve references to other components or HTML elements.
        node.refs.each do |variable, item|
          case item
          when Ast::HtmlComponent
            @ast
              .components
              .find(&.name.==(item.component.value))
              .try do |entity|
                map[variable.value] = entity
              end
          when Ast::HtmlElement
            map[variable.value] = item
          end
        end

        # Resolve connects to a store.
        node.connects.each do |connect|
          next unless store = @ast.stores.find(&.name.==(connect.store))

          resolved =
            resolve(store)

          connect.keys.each do |key|
            map[(key.name || key.variable).value] = resolved[key.variable.value]
          end
        end

        resolve(node.properties, map)
        resolve(node.functions, map)
        resolve(node.constants, map)
        resolve(node.states, map)
        resolve(node.gets, map)
      end

      def resolve(node : Ast::TupleDestructuring | Ast::EnumDestructuring, map : Map = Map.new) : Map
        node.parameters.each_with_object(map) do |parameter, memo|
          resolve(parameter, memo)
        end
      end

      def resolve(node : Ast::ArrayDestructuring, map : Map = Map.new) : Map
        node.items.each_with_object(map) do |item, memo|
          resolve(item, memo)
        end
      end

      def resolve(node : Ast::Variable, map : Map = Map.new) : Map
        map[node.value] = node
        map
      end

      private def resolve(properties : Array(Ast::Property), map : Map = Map.new) : Map
        properties.each_with_object(map) do |property, memo|
          memo[property.name.value] = property
        end
      end

      private def resolve(statements : Array(Ast::WhereStatement), map : Map = Map.new) : Map
        statements.each_with_object(map) do |statement, memo|
          statement.target.try { |target| resolve(target, memo) }
        end
      end

      private def resolve(functions : Array(Ast::Function), map : Map = Map.new) : Map
        functions.each_with_object(map) do |function, memo|
          memo[function.name.value] = function
        end
      end

      private def resolve(constants : Array(Ast::Constant), map : Map = Map.new) : Map
        constants.each_with_object(map) do |constant, memo|
          memo[constant.name] = constant
        end
      end

      private def resolve(arguments : Array(Ast::Argument), map : Map = Map.new) : Map
        arguments.each_with_object(map) do |argument, memo|
          memo[argument.name.value] = argument
        end
      end

      private def resolve(states : Array(Ast::State), map : Map = Map.new) : Map
        states.each_with_object(map) do |state, memo|
          memo[state.name.value] = state
        end
      end

      private def resolve(gets : Array(Ast::Get), map : Map = Map.new) : Map
        gets.each_with_object(map) do |get, memo|
          memo[get.name.value] = get
        end
      end
    end
  end
end
