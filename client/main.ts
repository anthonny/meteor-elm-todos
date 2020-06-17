import { init } from "meteor/elm-app";
import { Meteor } from "meteor/meteor";
import { Tracker } from "meteor/tracker";
import { TodosCollection } from "/imports/api/todos";

Meteor.startup(() => {
  const ports = init({
    node: document.getElementById("main"),
    flags: {},
  });

  ports.addTodo?.subscribe((todo) => {
    Meteor.call("todos.addTodo", todo, (err: Error) => {
      if (err) {
        // Maybe we should pass this error to Elm
        console.log("error", err);
        return;
      }
    });
  });

  ports.toggleStatus?.subscribe((todoId) => {
    Meteor.call("todos.toggleStatus", todoId, (err: Error) => {
      if (err) {
        // Maybe we should pass this error to Elm
        console.log("error", err);
        return;
      }
    });
  });

  Tracker.autorun(() => {
    // Maybe one day we will need to manage the subscription
    const subscription = Meteor.subscribe("todos");

    const todos = TodosCollection.find({}, { sort: { createdAt: 1 } }).fetch();

    ports.receiveTodos?.send(
      todos.map((todo) => ({
        id: todo._id || "",
        value: todo.value,
        status: todo.status,
      }))
    );
  });
});
