suite "@inline" {
  test "inlines the contents" {
    @inline(../../../spec/fixtures/data.txt) == "Hello World!\n"
  }
}

suite "@asset" {
  test "references the file" {
    @asset(../../../spec/fixtures/data.txt) == "/__mint__/data_8ddd8be4b179a529afa5f2ffae4b9858.txt"
  }
}

suite "@svg" {
  test "loads the file" {
    @svg(../../../spec/fixtures/icon.svg)
    |> Test.Html.start()
    |> Test.Html.assertElementExists("svg")
  }
}
