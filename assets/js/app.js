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
import { KanjiStrokeOrderAnimate } from "./hooks/kanji_stroke_order"
import { KanjiStrokeTracing } from "./hooks/kanji_tracing"
import AudioFeedback from "./hooks/audio_feedback"

// Shared swipe detection utility
function detectHorizontalSwipe(el, threshold, onSwipeLeft, onSwipeRight) {
  let startX = 0, startY = 0;
  el.addEventListener('touchstart', (e) => { startX = e.touches[0].clientX; startY = e.touches[0].clientY; });
  el.addEventListener('touchend', (e) => {
    if (!startX || !startY) return;
    const diffX = startX - e.changedTouches[0].clientX;
    const diffY = startY - e.changedTouches[0].clientY;
    if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > threshold) {
      diffX > 0 ? onSwipeLeft() : onSwipeRight();
    }
    startX = 0; startY = 0;
  });
}

// Define JS hooks for UI components
const Hooks = {
  AudioFeedback: AudioFeedback,
  KanjiStrokeOrderAnimate: KanjiStrokeOrderAnimate,
  KanjiStrokeTracing: KanjiStrokeTracing,
  StrokeOrderToggle: {
    mounted() {
      const scope = this.el.dataset.scope || "global";
      const key = `stroke_order_${scope}`;
      try {
        const stored = localStorage.getItem(key);
        if (stored === 'true' && this.el.dataset.initial !== 'true') {
          // Ask server to toggle on if not already
          this.pushEvent("toggle_stroke_order", {});
        }
      } catch (_) {}
    },
    updated() {
      const scope = this.el.dataset.scope || "global";
      const key = `stroke_order_${scope}`;
      const current = this.el.dataset.current === 'true';
      try { localStorage.setItem(key, current); } catch (_) {}
    }
  },
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
  SwipeTabNavigation: {
    mounted() {
      const threshold = parseInt(this.el.dataset.swipeThreshold) || 50;
      detectHorizontalSwipe(this.el, threshold,
        () => this.pushEvent("next_tab", {}),
        () => this.pushEvent("prev_tab", {})
      );
    }
  },
  // Quiz swipe: left swipe = next kanji (feedback mode), right swipe = skip (answer mode)
  MobileSwipeGestures: {
    mounted() {
      detectHorizontalSwipe(this.el, 50,
        () => {
          if (this.el.dataset.showFeedback === 'true') {
            this.pushEvent("next_kanji", {});
          }
        },
        () => {
          if (this.el.dataset.showFeedback === 'true') {
            this.pushEvent("next_kanji", {});
          } else {
            this.pushEvent("skip_kanji", {});
          }
        }
      );
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

// Listen for theme changes from the server
window.addEventListener("phx:theme-changed", (e) => {
  document.documentElement.setAttribute("data-theme", e.detail.theme);
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

