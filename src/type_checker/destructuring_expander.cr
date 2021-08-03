module Mint
  class TypeChecker
    # Enumerates all the possible destructuring options of a type.
    #
    # enum Status(a) {
    #  Loading
    #  Loaded(a)
    #  Idle
    # }
    #
    # expand(Tuple(String, String))
    #   {a, b}
    #
    # expand(Array(a))
    #   [a, b, ...]
    #   [..., a, b]
    #   [a, ...]
    #   [..., a]
    #   []
    #
    # expand(Status(Number))
    #   Status::Loaded(a)
    #   Status::Loading
    #   Status::Idle
    #
    # expand(Tuple(String, Status(Number))) ->
    #   {"value", Status::Loaded(a)}
    #   {"value", Status::Loading}
    #   {"value", Status::Idle}
    #   {a, Status::Loaded(b)}
    #   {a, Status::Loading}
    #   {a, Status::Idle}
    #   {a, b}
    #
    # expand(Array(Status(Number))) ->
    #   [Array(Status::Loaded(a)), ...]
    #   [Array(Status::Loading), ...]
    #   [Array(Status::Idle), ...]
    #   []
    class DestructuringExpander
      @var : String = 'a'.pred.to_s

      def initialize(@enums : Array(Ast::Enum), @depth : Int32 = 2)
      end

      def combine(parameters : Array(Array(String))) : Array(Array(String))
        return [] of Array(String) if parameters.empty?

        parameters[0].each_with_object([] of Array(String)) do |option, memo|
          combine(option, parameters[1..]).each do |combined|
            memo << combined
          end
        end
      end

      def combine(parameter : String, parameters : Array(Array(String))) : Array(Array(String))
        if parameters.size == 1
          parameters[0].map do |other_param|
            [parameter, other_param]
          end
        else
          parameters.each_with_object([] of Array(String)) do |options, memo|
            options.each do |option|
              combine(option, parameters[1..]).each do |combined|
                combined.unshift(parameter)
                memo << combined
              end
            end
          end
        end
      end

      def next_var
        @var = @var.succ
      end

      def expand(type : Variable) : Array(String)
        [next_var]
      end

      def expand(type : Record) : Array(String)
        [] of String
      end

      def expand(type : Type) : Array(String)
        expanded_parameters =
          type.parameters.map { |parameter| expand(parameter) }

        case type.name
        when "Tuple"
          combine(expanded_parameters).map do |params|
            "{#{params.join(", ")}}"
          end
        when "Array"
          [] of String
        else
          node = @enums.find(&.name.==(type.name))

          if node
            expanded = [] of String

            node.options.each do |option|
              name = "#{node.name}#{option.value}"

              if option.parameters.empty?
                expanded << name
              else
                combine(expanded_parameters).each do |array|
                  expanded << "#{name}(#{array.join(", ")})"
                end
              end
            end

            expanded
          else
            [next_var]
          end
        end
      end
    end
  end
end
