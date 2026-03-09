import gleam/dict
import gleeunit
import gleeunit/should
import simple_repl

pub fn command_lookup_test() {
  let commands =
    simple_repl.build_commands()
    |> simple_repl.commands_dict

  let has_help = case dict.get(commands, "help") {
    Ok(_) -> True
    Error(_) -> False
  }

  let has_unknown = case dict.get(commands, "foo") {
    Ok(_) -> True
    Error(_) -> False
  }

  has_help |> should.equal(True)
  has_unknown |> should.equal(False)
}

pub fn main() -> Nil {
  gleeunit.main()
}
