import gleam/dict
import gleam/io
import gleam/string
import simplifile

const history_file = ".history"

@external(erlang, "io", "get_line")
fn get_line(prompt: String) -> String

@external(erlang, "erlang", "halt")
fn halt(code: Int) -> Nil

fn clean() {
  case simplifile.delete(history_file) {
    Ok(Nil) -> Nil
    Error(e) -> io.println(simplifile.describe_error(e))
  }
}

fn history() {
  case simplifile.read(history_file) {
    Ok(content) -> io.print(content)
    Error(e) -> io.println(simplifile.describe_error(e))
  }
}

fn help() -> Nil {
  io.println("help: print this message")
  io.println("history: dump history")
  io.println("clean: delete history")
  io.println("exit: quit the program")
}

fn exit() -> Nil {
  halt(0)
}

fn commands() -> dict.Dict(String, fn() -> Nil) {
  dict.from_list([
    #("clean", clean),
    #("help", help),
    #("history", history),
    #("exit", exit),
  ])
}

fn append_history(cmd: String) -> Nil {
  case simplifile.append(history_file, cmd <> "\n") {
    Ok(Nil) -> Nil
    Error(e) -> io.println(simplifile.describe_error(e))
  }
}

fn repl_loop() -> a {
  let cmd = get_line("repl> ") |> string.trim
  cmd |> append_history
  case dict.get(commands(), cmd) {
    Ok(func) -> func()
    Error(_) -> io.println(cmd <> ": unknown command")
  }
  repl_loop()
}

pub fn main() -> Nil {
  case simplifile.is_file(history_file) {
    Ok(True) -> repl_loop()
    _ ->
      case simplifile.create_file(history_file) {
        Ok(Nil) -> repl_loop()
        Error(e) -> io.println(simplifile.describe_error(e))
      }
  }
}
