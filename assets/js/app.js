// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {}
Hooks.Table = {
  mounted() {
    console.log("mounted");

    // this.el.addEventListener("transitionend", some_function.bind(this, "aaa", "bbb"), false);
    this.el.addEventListener("transitionend", function() {
        // console.log("the orientation of the device is now ");
        // this.pushEvent("transitionend", { aaa: "bbb" });
        this.pushEvent("transitionend");
    }.bind(this));

  }
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
