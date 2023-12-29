module Mint
  class Compiler2
    # This class is resposible for creating a tree of JS code
    class Js
      # Whether or not to optimize the output.
      getter? optimize : Bool = false

      def initialize(@optimize)
      end

      # Renders an object. The key can be any item but it's usually a string
      # or an identifier.
      def object(items : Hash(Item, Compiled)) : Compiled
        return ["{}"] of Item if items.empty?

        fields =
          join(
            items.map { |key, value| [key, optimize? ? ":" : ": "] + value },
            optimize? ? "," : ",\n")

        block(fields)
      end

      # Renders an object destructuring.
      def object_destructuring(items : Array(Compiled)) : Compiled
        return ["{}"] of Item if items.empty?

        block(join(items, optimize? ? "," : ",\n"))
      end

      # Renders a call.
      def call(name : Item | Compiled, arguments : Array(Compiled)) : Compiled
        case name
        in Compiled
          name + ["("] + list(arguments) + [")"]
        in Item
          [name, "("] + list(arguments) + [")"]
        end
      end

      # Renders an array.
      def array(items : Array(Compiled)) : Compiled
        if optimize? || items.size <= 1
          ["["] + list(items) + ["]"]
        else
          ["[", Indent.new(["\n"] + list(items, multiline: true)), "\n]"] of Item
        end
      end

      # Renders statements.
      def statements(items : Array(Compiled)) : Compiled
        join(items.reject(&.empty?), optimize? ? ";" : ";\n")
      end

      # Renders a const assignment.
      def const(name : Item | Compiled, value : Compiled) : Compiled
        ["const "] + assign(name, value)
      end

      # Renders multiple const assignments (as one).
      def consts(items : Array(Tuple(Id, Compiled))) : Compiled
        if items.size == 1
          id, value =
            items[0]

          const id, value
        else
          assigns =
            items.map { |(id, compiled)| assign(id, compiled) }

          if optimize?
            ["const "] + list(assigns, multiline: false)
          else
            ["const"] + [Indent.new(["\n"] + list(assigns, multiline: true))] of Item
          end
        end
      end

      # Renders an initializer.
      def new(name : Item | Compiled, items : Array(Compiled)) : Compiled
        rest =
          if items.empty?
            case name
            in Compiled
              name
            in Item
              [name]
            end
          else
            call(name, items)
          end

        ["new "] + rest
      end

      # Renders a let assignment with multiple variables.
      def let(variables : Array(Variable)) : Compiled
        ["let "] + variables.map(&.as(Item)).intersperse(optimize? ? "," : ", ")
      end

      # Renders a let assignment.
      def let(name : Item | Compiled, value : Compiled) : Compiled
        ["let "] + assign(name, value)
      end

      # Renders an assignment.
      def assign(name : Item | Compiled, value : Compiled) : Compiled
        case name
        in Compiled
          name + [optimize? ? "=" : " = "] + value
        in Item
          ([name, optimize? ? "=" : " = "] of Item) + value
        end
      end

      # Renders an if statement.
      def if(condition : Compiled, body : Compiled) : Compiled
        ["if", optimize? ? "(" : " ("] + condition + [optimize? ? ")" : ") "] +
          block(body)
      end

      # Renders an tenary operator.
      def tenary(condition : Compiled, truthy : Compiled, falsy : Compiled)
        ["("] +
          condition +
          [optimize? ? "?" : " ? "] +
          truthy +
          [optimize? ? ":" : " : "] +
          falsy +
          [")"]
      end

      # Renders a for statement.
      def for(variables : Compiled, subject : Compiled, &) : Compiled
        ["for", optimize? ? "(" : " ("] +
          variables +
          [" of "] +
          subject +
          [optimize? ? ")" : ") "] +
          block(yield)
      end

      # Renders a return statement.
      def return(item : Compiled) : Compiled
        ["return "] + item
      end

      # Renders an async immediately invoked function.
      def asynciif(&) : Compiled
        function([] of Compiled, async: true, invoke: true) { yield }
      end

      # Renders an async immediately invoked function.
      def iif(&) : Compiled
        function([] of Compiled, async: false, invoke: true) { yield }
      end

      # Renders an async arrow function.
      def async_arrow_function(arguments : Array(Compiled) = [] of Compiled, &) : Compiled
        function(arguments, async: true, invoke: false) { yield }
      end

      # Renders an arrow function.
      def arrow_function(arguments : Array(Compiled) = [] of Compiled, &) : Compiled
        function(arguments, async: false, invoke: false) { yield }
      end

      # Renders an list (separated by commas).
      private def list(arguments : Array(Compiled), *, multiline : Bool = false) : Compiled
        if multiline
          join(arguments, ",\n")
        else
          join(arguments, optimize? ? "," : ", ")
        end
      end

      # Renders a function.
      private def function(
        arguments : Array(Compiled) = [] of Compiled, *,
        async : Bool, invoke : Bool, &
      )
        keyword =
          if async
            "async "
          else
            ""
          end

        items =
          block(yield)

        head, tail, parens =
          if invoke
            ["(", ")", "()"]
          else
            ["", "", ""]
          end

        [head, keyword, "("] +
          list(arguments) +
          [optimize? ? ")=>" : ") => "] +
          items +
          [tail, parens]
      end

      # Renders a block ({...}).
      private def block(items : Compiled) : Compiled
        if optimize?
          ["{"] + items + ["}"]
        else
          [Indent.new(["{\n"] + items), "\n}"] of Item
        end
      end

      # Joins the items with the given separator.
      private def join(items : Array(Compiled), separator : String) : Compiled
        items.reject(&.empty?).intersperse([separator]).flatten
      end
    end
  end
end
