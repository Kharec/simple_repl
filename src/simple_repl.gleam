import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import simplifile

const history_file = ".history"

@external(erlang, "io", "get_line")
fn get_line(prompt: String) -> String

@external(erlang, "erlang", "halt")
fn halt(code: Int) -> Nil

type Command {
  Command(name: String, description: String, run: fn(List(Command)) -> Nil)
}

fn clean(_cmds: List(Command)) -> Nil {
  case simplifile.delete(history_file) {
    Ok(Nil) -> Nil
    Error(e) -> io.println(simplifile.describe_error(e))
  }
}

fn history(_cmds: List(Command)) -> Nil {
  case simplifile.read(history_file) {
    Ok(content) -> io.print(content)
    Error(e) -> io.println(simplifile.describe_error(e))
  }
}

fn help(cmds: List(Command)) -> Nil {
  io.println("Available commands:")
  list.each(cmds, fn(cmd) {
    io.println("  " <> cmd.name <> " - " <> cmd.description)
  })
}

fn exit(_cmds: List(Command)) -> Nil {
  halt(0)
}

fn build_commands() -> List(Command) {
  [
    Command("clean", "delete history", clean),
    Command("help", "show this help", help),
    Command("history", "show history", history),
    Command("exit", "quit the program", exit),
  ]
}

fn commands_dict(
  cmds: List(Command),
) -> dict.Dict(String, fn(List(Command)) -> Nil) {
  list.fold(cmds, dict.new(), fn(acc, cmd) {
    dict.insert(acc, cmd.name, cmd.run)
  })
}

fn append_history(cmd: String) -> Nil {
  case simplifile.append(history_file, cmd <> "\n") {
    Ok(Nil) -> Nil
    Error(e) -> io.println(simplifile.describe_error(e))
  }
}

fn repl_loop(cmds: List(Command)) -> a {
  let input = get_line("repl> ") |> string.trim
  let cmd = string.lowercase(input)

  case cmd {
    "" -> Nil
    _ -> {
      input |> append_history
      case dict.get(commands_dict(cmds), cmd) {
        Ok(func) -> func(cmds)
        Error(_) -> io.println(input <> ": unknown command")
      }
    }
  }

  repl_loop(cmds)
}

pub fn main() -> Nil {
  let cmds = build_commands()
  case simplifile.is_file(history_file) {
    Ok(True) -> repl_loop(cmds)
    _ ->
      case simplifile.create_file(history_file) {
        Ok(Nil) -> repl_loop(cmds)
        Error(e) -> io.println(simplifile.describe_error(e))
      }
  }
}
