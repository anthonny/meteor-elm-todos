import { Mongo } from "meteor/mongo";
import { Meteor } from "meteor/meteor";

export interface Todo {
  _id?: string;
  value: string;
  status: "checked" | "unchecked";
  createdAt: Date;
}

export const TodosCollection = new Mongo.Collection<Todo>("todos");

Meteor.methods({
  "todos.addTodo"(value: string) {
    if (value !== "") {
      TodosCollection.insert({
        value,
        status: "unchecked",
        createdAt: new Date(),
      });
    }
  },
  "todos.toggleStatus"(todoId: string) {
    const todo = TodosCollection.findOne({ _id: todoId });
    if (!todo) {
      throw new Meteor.Error("Todo not found");
    }

    const newStatus = todo.status === "checked" ? "unchecked" : "checked";

    TodosCollection.update({ _id: todoId }, { $set: { status: newStatus } });
  },
});

if (Meteor.isServer) {
  Meteor.publish("todos", function todos() {
    return TodosCollection.find({}, { sort: { createdAt: -1 } });
  });
}
