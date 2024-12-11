import { hello } from "./example.js";

const event = 5; // Número de días a añadir
const context = {};
const callback = (error, result) => {
  if (error) {
    console.error("Error:", error);
  } else {
    console.log("Result:", result);
  }
};

// Invoca la función hello
hello(event, context, callback);