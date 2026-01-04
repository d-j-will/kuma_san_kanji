// assets/js/hooks/audio_feedback.js

const AudioFeedback = {
  mounted() {
    // Store reference to this hook for event handling
    const self = this; 
    let speechVoices = [];

    // Function to load voices, ensuring they are available before speaking
    const loadVoices = () => {
      speechVoices = window.speechSynthesis.getVoices();
    };

    // Load voices immediately and listen for changes
    loadVoices();
    if (window.speechSynthesis.onvoiceschanged !== undefined) {
      window.speechSynthesis.onvoiceschanged = loadVoices;
    }

    this.handleEvent("play_audio", ({ text, lang = "ja-JP", rate = 0.8 }) => {
      self.speak(self, text, lang, rate, speechVoices);
    });

    // Listen for local button clicks if configured
    this.el.addEventListener("click", (e) => {
      if (e.target.closest("[data-audio-text]")) {
        const btn = e.target.closest("[data-audio-text]");
        const text = btn.dataset.audioText;
        const lang = btn.dataset.audioLang || "ja-JP";
        const clickRate = parseFloat(btn.dataset.audioRate) || 0.8; // Retrieve rate from dataset or use default
        self.speak(self, text, lang, clickRate, speechVoices);
      }
    });
  },

  speak(hook, text, lang, rate, voices) {
    if (!("speechSynthesis" in window)) {
      console.warn("Web Speech API not supported.");
      return;
    }

    // Cancel any ongoing speech
    window.speechSynthesis.cancel();

    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = lang;
    utterance.rate = rate; // Slightly slower for clarity
    
    // Prefer Japanese voice if available, otherwise let browser pick default
    const jaVoice = voices.find(v => v.lang.includes("ja"));

    // If no Japanese voice is found, push an event to prompt the user
    if (!jaVoice) {
      hook.pushEventTo(hook.el.id, "japanese_voice_missing", {});
      console.warn("Japanese voice not found. Pushing event to prompt user.");
      // Do not proceed with speaking if no suitable voice is found
      return;
    }

    if (jaVoice) {
      utterance.voice = jaVoice;
    }

    // Workaround for some browsers not speaking immediately without a timeout
    setTimeout(() => {
        try {
            window.speechSynthesis.speak(utterance);
        } catch (e) {
            console.error("Error calling SpeechSynthesis.speak():", e);
            // Optionally, push a LiveView event to display a user-friendly error in the UI
            // this.pushEvent("speech_error", { message: "Failed to speak. Please check your system's Japanese voice settings." });
        }
    }, 100);
  }
};

export default AudioFeedback;
