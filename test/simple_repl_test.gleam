import gleam/list
import gleeunit
import gleeunit/should
import simple_repl

pub fn command_lookup_test() {
  let commands = simple_repl.build_commands()

  let has_help = case list.find(commands, fn(c) { c.name == "help" }) {
    Ok(_) -> True
    Error(_) -> False
  }

  let has_unknown = case list.find(commands, fn(c) { c.name == "foo" }) {
    Ok(_) -> True
    Error(_) -> False
  }

  has_help |> should.equal(True)
  has_unknown |> should.equal(False)
}

pub fn main() -> Nil {
  gleeunit.main()
}
