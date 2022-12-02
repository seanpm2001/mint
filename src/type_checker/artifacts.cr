module Mint
  class TypeChecker
    class Artifacts
      getter ast, lookups, cache, checked, record_field_lookup, assets
      getter types, variables, component_records, resolve_order
      getter enum_constructor_data, value_lookup

      def initialize(@ast : Ast,
                     @enum_constructor_data = {} of Ast::Node => {Record, Type},
                     @component_records = {} of Ast::Component => Record,
                     @record_field_lookup = {} of Ast::Node => String,
                     @variables = {} of Ast::Node => Scope::Lookup,
                     @value_lookup = {} of Ast::Node => Tuple(Ast::Node, Ast::Node?),
                     @lookups = {} of Ast::Node => Ast::Node,
                     @assets = [] of Ast::Directives::Asset,
                     @types = {} of Ast::Node => Checkable,
                     @cache = {} of Ast::Node => Checkable,
                     @resolve_order = [] of Ast::Node,
                     @checked = Set(Ast::Node).new)
      end
    end
  end
end
