export const KanjiStrokeOrderAnimate = {
  mounted() {
    this.prepare()
    this.registerEvents()
  },
  updated() {
    this.prepare()
  },
  prepare() {
    if (this.preparedKanji === this.el.dataset.kanji) return
    this.clearTimers()
    this.svg = this.el.querySelector('svg')
    if (!this.svg) return
    this.strokes = Array.from(this.svg.querySelectorAll('path[id*="-s"], path')).filter(p => p.getTotalLength)
    this.strokes.forEach((p, i) => {
      const len = p.getTotalLength()
      p.dataset.strokeIndex = i
      p.style.fill = 'none'
      p.style.strokeWidth = '3.2'
      p.style.strokeLinecap = 'round'
      p.style.strokeLinejoin = 'round'
      p.style.stroke = 'var(--stroke-base, #222)'
      p.style.strokeDasharray = len
      p.style.strokeDashoffset = len
      p.style.transition = 'stroke-dashoffset 0.45s ease, stroke 0.25s ease, filter 0.3s ease'
      p.style.filter = 'drop-shadow(1px 1px 2px oklch(12% 0.025 250 / 0.35))'
    })
    this.currentIndex = 0
    this.animating = false
    this.preparedKanji = this.el.dataset.kanji
  },
  clearTimers() {
    if (this.timers) this.timers.forEach(t => clearTimeout(t))
    this.timers = []
  },
  highlight(p) {
    this.strokes.forEach(s => { if (s !== p) { s.style.stroke = 'var(--stroke-base, #444)'; s.style.filter = 'drop-shadow(1px 1px 2px oklch(12% 0.025 250 / 0.25))' } })
    p.style.stroke = 'var(--stroke-active, oklch(42% 0.12 45))'
    p.style.filter = 'drop-shadow(2px 2px 4px oklch(12% 0.025 250 / 0.35))'
  },
  dehighlightAll() {
    this.strokes.forEach(s => { s.style.stroke = 'var(--stroke-base, #222)'; s.style.filter = 'drop-shadow(1px 1px 2px oklch(12% 0.025 250 / 0.25))' })
  },
  reset() {
    this.clearTimers()
    if (!this.strokes) return
    this.dehighlightAll()
    this.strokes.forEach(p => {
      const len = p.getTotalLength()
      p.style.transition = 'none'
      p.style.strokeDasharray = len
      p.style.strokeDashoffset = len
      void p.offsetWidth
      p.style.transition = 'stroke-dashoffset 0.45s ease, stroke 0.25s ease, filter 0.3s ease'
    })
    this.currentIndex = 0
    this.animating = false
  },
  replay() {
    if (!this.strokes || this.animating) return
    this.reset()
    this.animating = true
    let delay = 0
    this.strokes.forEach((p, idx) => {
      const len = p.getTotalLength()
      const dur = Math.min(1200, Math.max(250, len * 6))
      const t1 = setTimeout(() => {
        this.highlight(p)
        p.style.transition = `stroke-dashoffset ${dur}ms ease-out, stroke 0.25s ease, filter 0.3s ease`
        p.style.strokeDashoffset = 0
        const tClear = setTimeout(() => { if (idx !== this.strokes.length - 1) p.style.stroke = 'var(--stroke-done, #1a6fb3)' }, dur - 40)
        this.timers.push(tClear)
        if (idx === this.strokes.length - 1) {
          const t2 = setTimeout(() => { this.animating = false; this.dehighlightAll(); this.strokes.forEach(s=> s.style.stroke = 'var(--stroke-base, #222)') }, dur + 60)
          this.timers.push(t2)
        }
      }, delay)
      this.timers.push(t1)
      delay += dur + 120
    })
  },
  step() {
    if (!this.strokes) return
    if (this.animating) return
    if (this.currentIndex === 0) {
      this.reset()
    }
    if (this.currentIndex < this.strokes.length) {
      const p = this.strokes[this.currentIndex]
      const len = p.getTotalLength()
      this.highlight(p)
      p.style.transition = 'stroke-dashoffset 350ms ease-out, stroke 0.25s ease, filter 0.3s ease'
      p.style.strokeDasharray = len
      p.style.strokeDashoffset = 0
      const idxLocal = this.currentIndex
      const t = setTimeout(() => {
        p.style.stroke = 'var(--stroke-base, #222)'
        if (idxLocal === this.strokes.length - 1) {
          this.dehighlightAll()
        }
      }, 360)
      this.timers.push(t)
      this.currentIndex += 1
    } else {
      this.reset()
    }
  },
  registerEvents() {
    if (this.eventsRegistered) return
    this.handleEvent('stroke_order_restart', payload => {
      if (payload.kanji === this.el.dataset.kanji) this.replay()
    })
    this.handleEvent('stroke_order_step', payload => {
      if (payload.kanji === this.el.dataset.kanji) this.step()
    })
    this.handleEvent('stroke_order_toggle_style', payload => {
      if (payload.kanji === this.el.dataset.kanji) this.toggleStyle()
    })
    this.eventsRegistered = true
  },
  toggleStyle() {
    const mode = this.el.dataset.style === 'brush' ? 'clean' : 'brush'
    this.el.dataset.style = mode
    this.el.classList.toggle('brush', mode === 'brush')
    this.el.classList.toggle('clean', mode === 'clean')
    if (!this.strokes) return
    if (mode === 'clean') {
      this.strokes.forEach(p => {
        p.style.filter = 'none'
        p.style.strokeWidth = '2.6'
        p.style.strokeLinecap = 'round'
        p.style.strokeLinejoin = 'round'
      })
    } else {
      this.strokes.forEach(p => {
        p.style.filter = 'drop-shadow(1px 1px 2px oklch(12% 0.025 250 / 0.35))'
        p.style.strokeWidth = (3 + (Math.random()*0.5)).toFixed(2)
      })
    }
  }
};
