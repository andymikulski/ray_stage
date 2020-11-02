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
let displayedColor;
const existingColors = {};

let idx;
let r;
let g;
let b;

let drawingImage = new ImageData(1,1);
let drawingData = drawingImage.data;
drawingData[3]   = 255;

const hooks = {
  'RenderDisplay': {
    mounted() {
      this.toProcess = [];
      this.context = this.el.getContext('2d');
      width = this.el.width;
      console.log('Render Display mounted')

      this.handleEvent("pixel_update", ({pixels}) => {
        Array.prototype.push.apply(this.toProcess, pixels);
        // console.log('incoming', pixels.length);
      });

      this.tick();
    },
    tick() {
      i = 0;
      start = Date.now();
      // console.log('before start', this.toProcess.length)
      while(i < this.toProcess.length){ // } && start - Date.now() < thirty_fps) {
        idx = this.toProcess[i];
        r = this.toProcess[i + 1];
        g = this.toProcess[i + 2];
        b = this.toProcess[i + 3];

        existingColors[idx] = existingColors[idx] || [r,g,b];

        // r = Math.sqrt(((1 - (0.5)) * (r * r)) + ((0.5) * (existingColors[idx][0] * existingColors[idx][0])))
        // g = Math.sqrt(((1 - (0.5)) * (g * g)) + ((0.5) * (existingColors[idx][1] * existingColors[idx][1])))
        // b = Math.sqrt(((1 - (0.5)) * (g * g)) + ((0.5) * (existingColors[idx][2] * existingColors[idx][2])))

        r = (r + existingColors[idx][0]) / 2.0;
        g = (g + existingColors[idx][1]) / 2.0;
        b = (b + existingColors[idx][2]) / 2.0;


        // pix = this.toProcess.shift();
        // pix[0] // pixel idx
        // existingColors[pix[0]] = existingColors[pix[0]] || pix[1];

        // displayedColor = pix[1].map((val,idx)=>{
        //   // return (val + existingColors[pix[0]][idx] ) / 2;
        //   // return Math.min((val + existingColors[pix[0]][idx]) / 2, 1)
        //   return Math.sqrt((1 - (0.5)) * (val * val) + (0.5) * (existingColors[pix[0]][idx] * existingColors[pix[0]][idx]))
        // });

        // existingColors[pix[0]] = displayedColor;

        // pix[1] // [r,g,b] in ranging [0,1]
        y = (idx / width) | 0;
        x = idx - (y * width);

        // this.context.beginPath();
        // this.context.rect(x, y, 1, 1);
        // this.context.fillStyle = 'rgb(' + r + ',' + g + ',' + b + ')';
        // this.context.fill();
        // this.context.closePath();

        drawingData[0]   = r;
        drawingData[1]   = g;
        drawingData[2]   = b;
        this.context.putImageData( drawingImage, x, y );

        existingColors[idx] = [r,g,b]
        i += 4;
      }
      this.toProcess = this.toProcess.slice(i);
      // console.log('after', this.toProcess.length, i)
      // requestIdleCallback(this.tick.bind(this)); //,{ timeout: 1000 / 24 });
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

