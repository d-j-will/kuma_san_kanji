// assets/js/hooks/audio_feedback.js

const AudioFeedback = {
  mounted() {
    this.handleEvent("play_audio", ({ text, lang = "ja-JP", rate = 0.8 }) => {
      this.speak(text, lang, rate);
    });

    // Listen for local button clicks if configured
    this.el.addEventListener("click", (e) => {
      if (e.target.closest("[data-audio-text]")) {
        const btn = e.target.closest("[data-audio-text]");
        const text = btn.dataset.audioText;
        const lang = btn.dataset.audioLang || "ja-JP";
        this.speak(text, lang);
      }
    });
  },

  speak(text, lang, rate = 0.8) {
    if (!("speechSynthesis" in window)) {
      console.warn("Web Speech API not supported.");
      return;
    }

    // Cancel any ongoing speech
    window.speechSynthesis.cancel();

    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = lang;
    utterance.rate = rate; // Slightly slower for clarity
    
    // Prefer Japanese voice if available
    const voices = window.speechSynthesis.getVoices();
    const jaVoice = voices.find(v => v.lang.includes("ja"));
    if (jaVoice) {
      utterance.voice = jaVoice;
    }

    window.speechSynthesis.speak(utterance);
  }
};

export default AudioFeedback;
