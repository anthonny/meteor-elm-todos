import "./main.scss";
const { Elm } = require("./src/Main.elm");

interface Flags {}

export interface Configuration {
  node: HTMLElement | null;
  flags: Flags;
}

interface Todo {
  id: string;
  value: string;
  status: "checked" | "unchecked";
}

export interface Ports {
  addTodo?: {
    subscribe: (fn: (todo: string) => void) => void;
  };
  toggleStatus?: {
    subscribe: (fn: (todoId: string) => void) => void;
  };
  receiveTodos?: {
    send: (todos: Todo[]) => void;
  };
}

export const init: (configuration: Configuration) => Ports = (
  configuration
) => {
  const app = Elm.Main.init(configuration);
  return app.ports;
};
