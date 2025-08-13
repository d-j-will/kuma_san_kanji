// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Define JS hooks for UI components
const Hooks = {
  MobileMenu: {
    mounted() {
      this.el.addEventListener("toggle-mobile-menu", () => {
        const mobileMenu = document.getElementById("mobile-menu");
        if (mobileMenu.classList.contains("hidden")) {
          mobileMenu.classList.remove("hidden");
        } else {
          mobileMenu.classList.add("hidden");
        }
      });
    }
  },
  FocusInput: {
    mounted() {
      this.el.focus();
    },
    updated() {
      this.el.focus();
    }
  },
  MobileSwipeGestures: {
    mounted() {
      let startX = 0;
      let startY = 0;
      let threshold = 50; // minimum swipe distance
      
      this.el.addEventListener('touchstart', (e) => {
        startX = e.touches[0].clientX;
        startY = e.touches[0].clientY;
      });
      
      this.el.addEventListener('touchend', (e) => {
        if (!startX || !startY) return;
        
        let endX = e.changedTouches[0].clientX;
        let endY = e.changedTouches[0].clientY;
        
        let diffX = startX - endX;
        let diffY = startY - endY;
        
        // Check if horizontal swipe is longer than vertical (to avoid interference with scrolling)
        if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > threshold) {
          // Check if we're in feedback mode or answer mode
          const showFeedback = this.el.dataset.showFeedback === 'true';
          
          if (showFeedback) {
            // In feedback mode, any horizontal swipe goes to next kanji
            if (Math.abs(diffX) > threshold) {
              this.pushEvent("next_kanji", {});
            }
          } else {
            // In answer mode, right swipe skips kanji
            // diffX = startX - endX, so a right swipe makes diffX negative
            if (diffX < -threshold) {
              this.pushEvent("skip_kanji", {});
            }
          }
        }
        
        // Reset values
        startX = 0;
        startY = 0;
      });
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

