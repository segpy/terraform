import { hello } from "./example.js";

const event = 5; // Número de días a añadir
const context = {};

// Invoca la función hello
hello(event, context)
  .then(result => {
    console.log("Result:", result);
  })
  .catch(error => {
    console.error("Error:", error);
  });