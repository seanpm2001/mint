module Mint
  class Debugger
    def self.dbg(node)
      name =
        node.class.name.sub("Mint::Ast::", "")

      case x = node
      when Ast::Route
        "Route (#{x.url})"
      when Ast::Component
        "<#{x.name.value}>"
      when Ast::Module, Ast::Store, Ast::Provider, Ast::Type
        x.name.value
      when Ast::TypeDefinition
        "TD: #{x.name.value}"
      when Ast::TypeVariant
        dbg(x.parent) + "." + x.value.value
      when Ast::Function, Ast::Constant, Ast::Get, Ast::State, Ast::Property
        pn =
          case y = x.parent
          when Ast::Component, Ast::Module, Ast::Store, Ast::Provider
            y.name.value
          else
            ""
          end

        "#{pn}.#{x.name.value}"
      else
        name
      end
    end

    def initialize(@scope : TypeChecker::Scope)
    end

    def run
      @scope.levels.reverse.map_with_index do |level, index|
        debug(level).indent((index + 1) * 2)
      end.join('\n')
    end

    def debug(node : Ast::Node)
      node.to_s
    end

    def debug(node : Tuple(String, TypeChecker::Checkable, Ast::Node))
      "#{node[0]} => #{node[1]}"
    end

    def debug(node : Tuple(String, TypeChecker::Checkable))
      "#{node[0]} => #{node[1]}"
    end

    def debug(node : Ast::InlineFunction)
      node.arguments.join('\n') do |argument|
        "#{argument.name.value} => #{argument}"
      end
    end

    def debug(node : Ast::Function)
      node.arguments.join('\n') do |argument|
        "#{argument.name.value} => #{argument}"
      end
    end

    def debug(node : Ast::Get)
      ""
    end

    def debug(node : Ast::Module)
      node.functions.join('\n') do |function|
        "#{function.name.value} => #{function}"
      end
    end

    def debug(node : Ast::Store)
      functions =
        node.functions.join('\n') do |function|
          "#{function.name.value} => #{function}"
        end

      states =
        node.states.join('\n') do |state|
          "#{state.name.value} => #{state}"
        end

      gets =
        node.gets.join('\n') do |get|
          "#{get.name.value} => #{get}"
        end

      {functions, states, gets}.join('\n')
    end

    def debug(node : Ast::Component)
      functions =
        node.functions.join('\n') do |function|
          "#{function.name.value} => #{function}"
        end

      states =
        node.states.join('\n') do |state|
          "#{state.name.value} => #{state}"
        end

      properties =
        node.properties.join('\n') do |state|
          "#{state.name.value} => #{state}"
        end

      gets =
        node.gets.join('\n') do |get|
          "#{get.name.value} => #{get}"
        end

      {functions, states, gets, properties}.join('\n')
    end
  end
end
