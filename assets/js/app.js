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
import 'alpinejs'
import jQuery from "jquery"
import $ from "jquery"
global.$ = global.jQuery = $;
import "../node_modules/fomantic-ui-css/semantic.min.js";

let Hooks = {}
Hooks.Table = {
  mounted() {
    console.log("mounted");
    // this.mouse_down = false;
    // this.el.addEventListener("transitionend", some_function.bind(this, "aaa", "bbb"), false);
    let el = this.el;
    let my = this;
    const debounce_interval = 20;
    let last = Date.now() - debounce_interval;

    this.el.addEventListener("mousedown", (e) => {
      console.log("mouse down");
      console.log(e);
      e.stopPropagation();

      const prevX = e.clientX;
      const width = el.parentElement.offsetWidth;

      window.addEventListener("mousemove", mousemove);
      window.addEventListener("mouseup", mouseup);

      function mousemove(e) {

        console.log("mouse move");
        e.stopPropagation();
        let diffX = e.clientX - prevX;

        const now = Date.now();
        if ((now - last) > debounce_interval) {
          el.parentElement.setAttribute("width", width + diffX + "px");

          last = now;
        }

      }

      function mouseup(e) {
        console.log("mouse up");
        e.stopPropagation();

        const title = el.parentElement.title;
        const target = el.parentElement.getAttribute("phx-target");
        const width = el.parentElement.offsetWidth;

        my.pushEventTo(target, "resize", {
            title: title,
            width: width
        });

        // this.mouse_down = false;
        window.removeEventListener("mousemove", mousemove);
        window.removeEventListener("mouseup", mouseup);

        console.log("mouse up done");
      }

    });
    // .bind(this));
  }
}
Hooks.Popup = {
  mounted() {
      $(this.el).popup({
          inline: true
      });
  }
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken},
  dom: {
    onBeforeElUpdated(from, to){
      if(from.__x){ window.Alpine.clone(from.__x, to) }
    }
  }
});
// , dom: {
//   onBeforeElUpdated(from, to) {
//     if (from.__x) { window.Alpine.clone(from.__x, to) }
//   }
// }});

liveSocket.connect()


// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
