// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

const one_twenty_fps = 1000 / 120;
const sixty_fps = 1000 / 60;
const thirty_fps = 1000 / 30;
const ten_fps = 1000 / 10;
let start = Date.now();
let pix;
let i = 0;
let y = 0;
let x = 0;
let width = 0;
const binary_to_rgb = x => Math.round(x * 255)
const hooks = {
  'RenderDisplay': {
    mounted() {
      this.toProcess = [];
      this.context = this.el.getContext('2d');
      width = this.el.width;
      console.log('Render Display mounted')

      this.handleEvent("pixel_update", ({pixels}) => {
        this.toProcess = this.toProcess.concat(pixels);
      });

      this.tick();
    },
    tick() {
      i = 0;
      start = Date.now();
      while(i < this.toProcess.length && start - Date.now() < thirty_fps) {
        pix = this.toProcess.shift();
        // pix[0] // pixel idx
        // pix[1] // [r,g,b] in ranging [0,1]
        y = (pix[0] / width) | 0;
        x = pix[0] - (y * width);

        this.context.beginPath();
        this.context.rect(x, y, 1, 1);
        this.context.fillStyle = 'rgb(' + (pix[1].map(binary_to_rgb).join(',')) + ')';
        this.context.fill();
        this.context.closePath();

        i += 1;
      }
      // requestIdleCallback(this.tick.bind(this),{ timeout: 1000 / 24 });
      requestAnimationFrame(this.tick.bind(this));
    }
  }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

