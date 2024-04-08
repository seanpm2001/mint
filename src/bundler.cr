module Mint
  # This class is responsible for compiling and building the application.
  class Bundler
    alias Bundle = Compiler2::Bundle

    record Config,
      test : NamedTuple(url: String, id: String)?,
      generate_manifest : Bool,
      include_program : Bool,
      runtime_path : String?,
      live_reload : Bool,
      hash_assets : Bool,
      skip_icons : Bool,
      relative : Bool,
      optimize : Bool

    # The end result of the bundling. It contains the all the files for the
    # application.
    getter files = {} of String => Proc(String)

    # The artifacts to bundle.
    getter artifacts : TypeChecker::Artifacts

    # The bundle configuration.
    getter config : Config

    # The application configuration.
    getter json : MintJson

    # Contains the names of the bundles.
    getter bundle_names = {} of Ast::Node | Bundle => String

    delegate application, to: json

    def initialize(*, @config, @artifacts, @json)
      @bundle_counter = 0
    end

    def bundle
      generate_application
      generate_index_html
      generate_manifest if config.generate_manifest
      generate_icons unless config.skip_icons
      generate_assets

      files
    end

    def generate_application
      compiler =
        Compiler2.new(artifacts, application.css_prefix, config)

      # Gather all top level entities and resolve them, this will populate the
      # `compiled` instance variable of the compiler.
      # entities =
      (artifacts.ast.type_definitions +
        artifacts.ast.unified_modules +
        artifacts.ast.components +
        artifacts.ast.providers +
        artifacts.ast.stores).tap { |items| compiler.resolve(items) }

      # Compile the CSS.
      files[path_for_asset("index.css")] =
        ->{ compiler.style_builder.compile }

      # Compile tests if there is configration for it.
      tests =
        if test_information = config.test
          [
            compiler.test(test_information[:url], test_information[:id]),
          ]
        end

      # This holds the to be compiled constants per bundle. `Bundle::Index` holds
      # the ones meant for the main bundle.
      bundles =
        {
          Bundle::Index => ([] of Tuple(Ast::Node, Compiler2::Id, Compiler2::Compiled)),
        } of Ast::Node | Bundle => Array(Tuple(Ast::Node, Compiler2::Id, Compiler2::Compiled))

      # This holds which node belongs to which bundle.
      scopes =
        {} of Ast::Node => Ast::Node

      # Gather all of the IDs so we can use it to filter out imports later on.
      ids =
        compiler.compiled.map { |(_, id, _)| id }

      # We iterate through all references and decide in which bundle they
      # belong. All nodes that needs to be compiled should be in the
      # references map.
      artifacts.references.map do |node, set|
        # Gather all related nodes.
        nodes =
          compiler.compiled.select { |item| item[1] == node }

        # Delete the nodes so we know after which was not used so we can
        # add it to the main bundle.
        nodes.each { |item| compiler.compiled.delete(item) }

        case node
        when Ast::Defer
          bundles[node] ||= [] of Tuple(Ast::Node, Compiler2::Id, Compiler2::Compiled)
          bundles[node].concat(nodes)
        when Ast::Component
          # We put async components into their own bundle.
          if node.async?
            bundles[node] ||= [] of Tuple(Ast::Node, Compiler2::Id, Compiler2::Compiled)
            bundles[node].concat(nodes)

            # Add the lazy component definition to the main bundle.
            bundles[Bundle::Index] << {
              node,
              node,
              compiler.js.call(
                Compiler2::Builtin::Lazy,
                [[Compiler2::Deferred.new(node)] of Compiler2::Item]),
            }
          end
        end ||
          # If a node used in the main bundle or it two or more bundles then
          # it will go into the main bundle. Otherwise it will go to the
          # the bundle it's used from.
          if set.includes?(nil) || (!set.includes?(nil) && set.size >= 2)
            bundles[Bundle::Index].concat(nodes)
          elsif first = set.first
            bundles[first] ||= [] of Tuple(Ast::Node, Compiler2::Id, Compiler2::Compiled)
            bundles[first].concat(nodes)

            # Assign the scope to the node
            scopes[node] = first
          end
      end

      # Add not already added items to the main bundle.
      bundles[Bundle::Index].concat(compiler.compiled)

      # bundles.each do |node, items|
      #   entities =
      #     items.compact_map do |item|
      #       if item[0] == node
      #         next if node.is_a?(Ast::Defer)
      #       else
      #         next if item[0].is_a?(Ast::Component) &&
      #                 item[0].as(Ast::Component).async?
      #       end

      #       Debugger.dbg(item[0])
      #     end

      #   puts compiler.path_for_bundle(node)
      #   entities.sort.each do |item|
      #     puts " > #{item}"
      #   end
      # end

      class_pool =
        NamePool(Ast::Node | Compiler2::Builtin, Ast::Node | Bundle).new('A'.pred.to_s)

      pool =
        NamePool(Ast::Node | Compiler2::Variable | String, Ast::Node | Bundle).new

      rendered_bundles =
        {} of Ast::Node | Bundle => Tuple(Compiler2::Renderer, Array(String))

      # We render the bundles so we can know after what we need to import.
      bundles.each do |node, contents|
        renderer =
          Compiler2::Renderer.new(
            bundle_path: ->path_for_bundle(Ast::Node | Bundle),
            deferred_path: ->bundle_name(Ast::Node | Bundle),
            class_pool: class_pool,
            bundles: bundles,
            base: node,
            pool: pool)

        # Built the singe `const` with multiple assignments so we can add
        # things later to the array.
        items =
          if contents.empty?
            [] of Compiler2::Compiled
          else
            # Here we sort the compiled node by the order they are resovled, which
            # will prevent issues of one entity depending on others (like a const
            # depending on a function from a module).
            contents.sort_by! do |(node, id, _)|
              case node
              when Ast::TypeVariant
                -2 if node.value.value.in?("Just", "Nothing", "Err", "Ok")
              end || artifacts.resolve_order.index(node) || -1
            end

            [["export "] + compiler.js.consts(contents)]
          end

        # If we are building the main bundle we add the translations, tests
        # and the program.
        case node
        when Bundle::Index
          # Add translations and tests
          items.concat compiler.translations
          items.concat tests if tests

          # Add the program if needed.
          items << compiler.program if config.include_program
        end

        # Render the final JavaScript.
        items =
          items.reject(&.empty?).map { |item| renderer.render(item) }

        rendered_bundles[node] = {renderer, items}
      end

      rendered_bundles.each do |node, (renderer, items)|
        case node
        when Bundle::Index
          # Index doesn't import from other nodes.
        else
          # This holds the imports for each other bundle.
          imports =
            {} of Ast::Node | Bundle => Hash(String, String)

          renderer.used.map do |item|
            # We only need to import things that are actually exported (all
            # other entities show up here like function arguments statement
            # variables, etc...)
            next unless ids.includes?(item)

            # Get where the entity should be.
            target =
              scopes[item]? || Bundle::Index

            # If the target is not this bundle and it's not the same bundle
            # then we need to import.
            if target != node && item != node
              exported_name =
                rendered_bundles[target][0].render(item).to_s

              imported_name =
                renderer.render(item).to_s

              imports[target] ||= {} of String => String
              imports[target][exported_name] = imported_name
            end
          end

          # For each import we insert an import statement.
          imports.each do |target, data|
            items.unshift(
              renderer.import(
                data,
                config.optimize,
                path_for_import(target)))
          end

          case node
          when Ast::Node
            items << "export default #{renderer.render(node)}" if node
          end
        end

        # Gather what builtins need to be imported and add it's statement
        # as well.
        builtins =
          renderer
            .builtins
            .each_with_object({} of String => String) do |item, memo|
              memo[item.to_s.camelcase(lower: true)] = renderer.class_pool.of(item, node)
            end

        items
          .unshift(renderer.import(builtins, config.optimize, "./runtime.js"))
          .reject!(&.blank?)

        js =
          if items.empty?
            ""
          elsif config.optimize
            items.join(";")
          else
            items.join(";\n\n") + ";"
          end

        files[path_for_bundle(node)] = ->{ js }
      end
    end

    def generate_index_html
      files["index.html"] = ->do
        HtmlBuilder.build(optimize: config.optimize) do
          html do
            head do
              meta charset: application.meta["charset"]? || "utf-8"

              if config.generate_manifest
                link rel: "manifest", href: "manifest.webmanifest"
              end

              application.meta.each do |name, content|
                next if name == "charset"
                meta name: name, content: content
              end

              unless application.theme.blank?
                meta name: "theme-color", content: application.theme
              end

              if generate_icons?
                ICON_SIZES.each do |size|
                  link href: path_for_asset("icon-#{size}x#{size}.png"),
                    size: "#{size}x#{size}",
                    type: "image/png",
                    rel: "icon"
                end

                {152, 167, 180}.each do |size|
                  link href: path_for_asset("icon-#{size}x#{size}.png"),
                    rel: "apple-touch-icon-precomposed"
                end
              end

              link rel: "stylesheet", href: path_for_asset("index.css")
              raw application.head
            end

            body do
              if config.live_reload
                script src: path_for_asset("live-reload.js")
              end

              script type: "module" do
                raw <<-TEXT
                import Program from "#{path_for_asset("index.js")}"
                Program()
                TEXT
              end

              noscript do
                text "This application requires JavaScript."
              end

              if item = config.test
                script do
                  raw %(window.TEST_ID = "#{item[:id]}";)
                end

                div id: "root"
              end
            end
          end
        end
      end
    end

    def generate_manifest
      files["manifest.webmanifest"] = ->do
        icons =
          if generate_icons?
            ICON_SIZES.map do |size|
              {
                "src"   => "icon-#{size}x#{size}.png",
                "sizes" => "#{size}x#{size}",
                "type"  => "image/png",
              }
            end
          else
            %w[]
          end
        {
          "orientation"      => application.orientation,
          "display"          => application.display,
          "background_color" => application.theme,
          "theme_color"      => application.theme,
          "name"             => application.name,
          "short_name"       => application.name,
          "icons"            => icons,
          "start_url"        => "/",
        }.to_pretty_json
      end
    end

    def generate_icons?
      !config.skip_icons &&
        Process.find_executable("convert") &&
        File.exists?(json.application.icon)
    end

    def generate_icons
      return unless generate_icons?

      ICON_SIZES.each do |size|
        files[path_for_asset("icon-#{size}x#{size}.png")] =
          ->{ IconGenerator.convert(json.application.icon, size) }
      end
    end

    def generate_assets
      artifacts
        .assets
        .uniq(&.real_path)
        .select!(&.exists?)
        .each do |asset|
          path =
            path_for_asset(asset.filename(build: config.hash_assets))

          files[path] = ->{ asset.file_contents }
        end

      if Dir.exists?(PUBLIC_DIR)
        Dir.glob(Path[PUBLIC_DIR, "**", "*"]).each do |path|
          parts =
            Path[path].parts.tap(&.shift)

          files["/#{parts.join("/")}"] = ->{ File.read(path) }
        end
      end

      files[path_for_asset("runtime.js")] =
        if runtime_path = config.runtime_path
          ->{ File.read(runtime_path) }
        elsif config.test
          ->{ Assets.read("runtime_test.js") }
        else
          ->{ Assets.read("runtime.js") }
        end

      if config.live_reload
        files[path_for_asset("live-reload.js")] =
          ->{ Assets.read("live-reload.js") }
      end
    end

    def path_for_asset(filename : String) : String
      "#{config.relative ? "" : "/"}#{ASSET_DIR}/#{filename}"
    end

    def bundle_name(node : Ast::Node | Bundle) : String
      @bundle_names[node] ||= begin
        case node
        when Ast::Directives::FileBased
          node.filename(build: config.hash_assets)
        when Bundle::Index
          "index.js"
        else
          "#{@bundle_counter += 1}.js"
        end
      end
    end

    def path_for_import(node : Ast::Node | Bundle) : String
      "./#{bundle_name(node)}"
    end

    def path_for_bundle(node : Ast::Node | Bundle) : String
      path_for_asset(bundle_name(node))
    end
  end
end
