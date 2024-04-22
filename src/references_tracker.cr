module Mint
  class ReferencesTracker
    alias Bundles = Hash(Ast::Node | Bundle, Set(Ast::Node))
    alias Bundle = Compiler2::Bundle

    # This hash tracks the links between nodes.
    @mapping = {} of Ast::Node => Set(Ast::Node)

    # This hash contains the final mapping of which
    # bundle contains which node (inverse of bundles).
    @bundle_mapping = {} of Ast::Node => Ast::Node | Bundle

    # This hash contains which nodes belong to which bundle.
    getter bundles = Bundles.new

    def initialize(@io : IO? = nil)
    end

    # Adds a dependency link (node depends on target).
    def add(node, target)
      @mapping[node] ||= Set(Ast::Node).new
      @mapping[node].add(target)
    end

    # Returns the bundle of the node.
    def bundle_of(node : Ast::Node) : Ast::Node | Bundle
      @bundle_mapping[node]? || Bundle::Index
    end

    # Calculates which node belongs to which bundle.
    def calculate(nodes : Set(Ast::Node)) : Bundles
      # These will be the bundles, plus the index.
      target_bundles =
        nodes.select(Ast::Component).select(&.async?) +
          nodes.select(Ast::Defer)

      # Get the bundles of the top-level entities.
      bundles =
        calculate

      # All the nodes that needs to be in a bundle.
      target_nodes =
        bundles
          .values
          .flat_map(&.to_a)

      # We gather all the nodes which are used more than once.
      multi_uses =
        target_nodes
          .tally({} of Ast::Node => Int32)
          .select { |_, count| count >= 2 }
          .keys
          .to_set

      # Remove the multi used nodes from the bundles.
      bundles.transform_values! { |dependencies| dependencies - multi_uses }

      # Find all the nodes which are not in a target bundle.
      not_bundled =
        bundles
          .reject { |key, _| target_bundles.includes?(key) }
          .values
          .flat_map(&.to_a)
          .to_set

      # The index bundle is the differenc of all the nodes and
      # the nodes which are only used by one bundle.
      index_bundle =
        (nodes - (target_nodes.to_set - multi_uses)) + not_bundled

      # We put together the final bundles.
      bundles
        .select { |key, _| target_bundles.includes?(key) }
        .tap(&.[]=(Bundle::Index, index_bundle))
        .tap(&.each do |bundle, dependencies|
          dependencies.each { |node| @bundle_mapping[node] = bundle }
          @bundles[bundle] = dependencies
        end)
    end

    # We go through each top-level entity and calculate their dependencies.
    private def calculate : Bundles
      @mapping
        .keys
        .each_with_object(Bundles.new) do |node, sets|
          case node
          when Ast::TypeDefinition,
               Ast::Component,
               Ast::Provider,
               Ast::Module,
               Ast::Routes,
               Ast::Locale,
               Ast::Store,
               Ast::Suite,
               Ast::Defer
            sets[node] = calculate node: node, base: node
          end
        end
    end

    private def calculate(
      *,
      dependencies = Set(Ast::Node).new,
      node : Ast::Node,
      base : Ast::Node,
      level = 0
    ) : Set(Ast::Node)
      # We add the node as a dependency.
      case node
      when Ast::TypeDefinition,
           Ast::HtmlComponent,
           Ast::Component,
           Ast::Constant,
           Ast::Property,
           Ast::Function,
           Ast::Provider,
           Ast::Module,
           Ast::Defer,
           Ast::State,
           Ast::Store,
           Ast::Get
        dependencies.add(node)
      end

      if level.zero?
        log Debugger.dbg(node)
      else
        log "➔ #{Debugger.dbg(node)}".indent(level * 2)
      end

      # We find it's dependencies and iterate over them.
      @mapping[node]?.try(&.each do |item|
        case item
        when Ast::Component
          # If we hit async components we don't track them.
          # They will be handled in the bundler.
          next if item != base && item.async?
        when Ast::Defer
          # If we hit defers we add them, but don't track their
          # dependencies since they are their dependencies.
          if item != base
            log "➔ #{Debugger.dbg(item)}".indent((level + 1) * 2)
            dependencies.add(node)
            next
          end
        when Ast::TypeDefinition,
             Ast::Provider,
             Ast::Module,
             Ast::Routes,
             Ast::Locale,
             Ast::Store,
             Ast::Suite
          # We don't track top level dependencies to avoid
          # them leaking into other top level entities.
          next if item != base
        end ||
          case item
          when Ast::Property
            # We don't track properties because they
            # belong with their components.
            next if item.parent != base
          end || calculate(
          dependencies: dependencies,
          level: level + 1,
          node: item,
          base: base)
      end)

      dependencies
    end

    private def log(message)
      @io.try(&.puts(message))
    end
  end
end
