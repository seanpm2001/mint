require "./spec_helper"

describe "DestructuringExpander" do
  it "expands all possible case branches" do
    source =
      <<-SOURCE
      enum Status(a, b) {
        Loaded(a, b)
        Loading
        Idle
      }
      SOURCE

    ast = Mint::Parser.parse(source, "source.mint")

    expander =
      Mint::TypeChecker::DestructuringExpander.new(ast.enums)

    # pp expander.expand(Mint::TypeChecker::Variable.new("a"))
    # pp expander.expand(Mint::TypeChecker::Type.new("Tuple", [
    #   Mint::TypeChecker::Variable.new("a").as(Mint::TypeChecker::Checkable),
    #   Mint::TypeChecker::Variable.new("b").as(Mint::TypeChecker::Checkable),
    # ]))

    # pp expander.expand(
    #   Mint::TypeChecker::Type.new("Tuple",
    #     [
    #       Mint::TypeChecker::Type.new("Status", [
    #         Mint::TypeChecker::Type.new("Number"),
    #         Mint::TypeChecker::Type.new("Bool"),
    #       ] of Mint::TypeChecker::Checkable),
    #       Mint::TypeChecker::Variable.new("Number"),
    #     ] of Mint::TypeChecker::Checkable))

    pp expander.expand(
      Mint::TypeChecker::Type.new("Tuple",
        [
          Mint::TypeChecker::Type.new("Status", [
            Mint::TypeChecker::Type.new("Number"),
            Mint::TypeChecker::Type.new("Status", [
              Mint::TypeChecker::Type.new("String"),
              Mint::TypeChecker::Type.new("Tuple",
                [
                  Mint::TypeChecker::Type.new("String"),
                  Mint::TypeChecker::Type.new("Number"),
                  Mint::TypeChecker::Type.new("Bool"),
                ] of Mint::TypeChecker::Checkable),
            ] of Mint::TypeChecker::Checkable),
          ] of Mint::TypeChecker::Checkable),
          Mint::TypeChecker::Variable.new("Number"),
        ] of Mint::TypeChecker::Checkable))

    # pp expander.combine([
    #   ["Status::Loading(a)", "Status::Loaded", "Status::Idle"],
    #   ["Status::Loading(a)", "Status::Loaded", "Status::Idle"],
    #   # ["Status::Loading(a)", "Status::Loaded", "Status::Idle"],
    # ])
  end
end
