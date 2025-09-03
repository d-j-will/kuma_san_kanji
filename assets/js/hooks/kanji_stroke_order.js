/**
 * Modern ES6+ Kanji Stroke Order Animation Hook
 * Provides smooth stroke-by-stroke animation for KanjiVG SVG data
 */

// CSS Custom Properties for theming
const STROKE_STYLES = {
  base: 'var(--stroke-base, #222)',
  baseHighlight: 'var(--stroke-base, #444)', 
  active: 'var(--stroke-active, oklch(42% 0.12 45))',
  done: 'var(--stroke-done, #1a6fb3)'
};

const SHADOW_STYLES = {
  base: 'drop-shadow(1px 1px 2px oklch(12% 0.025 250 / 0.35))',
  baseLight: 'drop-shadow(1px 1px 2px oklch(12% 0.025 250 / 0.25))',
  active: 'drop-shadow(2px 2px 4px oklch(12% 0.025 250 / 0.35))'
};

const ANIMATION_CONFIG = {
  initialDelay: 400, // ms pause before animation starts
  strokeDelay: 120, // ms between stroke animations
  stepDuration: 350, // ms for step-by-step animation
  finishDelay: 60, // ms delay after final stroke
  transitionBase: 'stroke-dashoffset 0.45s ease, stroke 0.25s ease, filter 0.3s ease'
};

class StrokeOrderAnimator {
  constructor(element) {
    this.el = element;
    this.svg = null;
    this.strokes = [];
    this.timers = [];
    this.currentIndex = 0;
    this.animating = false;
    this.preparedKanji = null;
    this.eventsRegistered = false;
  }

  /**
   * Initialize stroke paths and set them to hidden state
   */
  prepare() {
    if (this.preparedKanji === this.el.dataset.kanji) return;
    
    this.clearTimers();
    this.svg = this.el.querySelector('svg');
    if (!this.svg) return;
    
    // Get all stroke paths and immediately hide them
    const allPaths = Array.from(this.svg.querySelectorAll('path[id*="-s"], path'))
      .filter(path => path.getTotalLength);
    
    this.hideStrokesInstantly(allPaths);
    this.setupStrokeStyles(allPaths);
    
    this.strokes = allPaths;
    this.currentIndex = 0;
    this.animating = false;
    this.preparedKanji = this.el.dataset.kanji;
  }

  /**
   * Instantly hide all strokes without animation
   */
  hideStrokesInstantly(paths) {
    paths.forEach(path => {
      const length = path.getTotalLength();
      path.style.transition = 'none';
      path.style.strokeDasharray = length;
      path.style.strokeDashoffset = length;
    });
  }

  /**
   * Apply consistent styling to all stroke paths
   */
  setupStrokeStyles(paths) {
    paths.forEach((path, index) => {
      const length = path.getTotalLength();
      
      // Set stroke metadata
      path.dataset.strokeIndex = index;
      
      // Apply base styles
      Object.assign(path.style, {
        fill: 'none',
        strokeWidth: '3.2',
        strokeLinecap: 'round',
        strokeLinejoin: 'round',
        stroke: STROKE_STYLES.base,
        strokeDasharray: length,
        strokeDashoffset: length,
        transition: 'none',
        filter: SHADOW_STYLES.base
      });
      
      // Force repaint and enable transitions
      void path.offsetWidth;
      path.style.transition = ANIMATION_CONFIG.transitionBase;
    });
  }

  /**
   * Clear all active timers
   */
  clearTimers() {
    this.timers.forEach(timer => clearTimeout(timer));
    this.timers = [];
  }

  /**
   * Highlight a specific stroke path
   */
  highlightStroke(targetPath) {
    this.strokes.forEach(path => {
      if (path !== targetPath) {
        path.style.stroke = STROKE_STYLES.baseHighlight;
        path.style.filter = SHADOW_STYLES.baseLight;
      }
    });
    
    targetPath.style.stroke = STROKE_STYLES.active;
    targetPath.style.filter = SHADOW_STYLES.active;
  }

  /**
   * Remove highlighting from all strokes
   */
  dehighlightAll() {
    this.strokes.forEach(stroke => {
      stroke.style.stroke = STROKE_STYLES.base;
      stroke.style.filter = SHADOW_STYLES.baseLight;
    });
  }

  /**
   * Reset all strokes to hidden state
   */
  reset() {
    this.clearTimers();
    if (!this.strokes?.length) return;
    
    this.dehighlightAll();
    
    this.strokes.forEach(path => {
      const length = path.getTotalLength();
      path.style.transition = 'none';
      path.style.strokeDasharray = length;
      path.style.strokeDashoffset = length;
      void path.offsetWidth;
      path.style.transition = ANIMATION_CONFIG.transitionBase;
    });
    
    this.currentIndex = 0;
    this.animating = false;
  }

  /**
   * Calculate animation duration based on stroke complexity
   */
  calculateStrokeDuration(pathLength) {
    return Math.min(1200, Math.max(250, pathLength * 6));
  }

  /**
   * Animate a single stroke
   */
  animateStroke(path, index, duration, delay) {
    const timer = setTimeout(() => {
      this.highlightStroke(path);
      path.style.transition = `stroke-dashoffset ${duration}ms ease-out, stroke 0.25s ease, filter 0.3s ease`;
      path.style.strokeDashoffset = 0;
      
      // Mark stroke as completed after animation
      const completeTimer = setTimeout(() => {
        if (index !== this.strokes.length - 1) {
          path.style.stroke = STROKE_STYLES.done;
        }
      }, duration - 40);
      
      this.timers.push(completeTimer);
      
      // Handle final stroke completion
      if (index === this.strokes.length - 1) {
        const finishTimer = setTimeout(() => {
          this.animating = false;
          this.dehighlightAll();
          this.strokes.forEach(stroke => {
            stroke.style.stroke = STROKE_STYLES.base;
          });
        }, duration + ANIMATION_CONFIG.finishDelay);
        
        this.timers.push(finishTimer);
      }
    }, delay);
    
    this.timers.push(timer);
  }

  /**
   * Play full stroke order animation with initial delay
   */
  replay() {
    if (!this.strokes?.length || this.animating) return;
    
    this.reset();
    this.animating = true;
    
    let currentDelay = ANIMATION_CONFIG.initialDelay;
    
    this.strokes.forEach((path, index) => {
      const pathLength = path.getTotalLength();
      const duration = this.calculateStrokeDuration(pathLength);
      
      this.animateStroke(path, index, duration, currentDelay);
      currentDelay += duration + ANIMATION_CONFIG.strokeDelay;
    });
  }

  /**
   * Step through strokes one at a time
   */
  step() {
    if (!this.strokes?.length || this.animating) return;
    
    if (this.currentIndex === 0) {
      this.reset();
    }
    
    if (this.currentIndex < this.strokes.length) {
      const path = this.strokes[this.currentIndex];
      const length = path.getTotalLength();
      
      this.highlightStroke(path);
      path.style.transition = `stroke-dashoffset ${ANIMATION_CONFIG.stepDuration}ms ease-out, stroke 0.25s ease, filter 0.3s ease`;
      path.style.strokeDasharray = length;
      path.style.strokeDashoffset = 0;
      
      const currentIdx = this.currentIndex;
      const timer = setTimeout(() => {
        path.style.stroke = STROKE_STYLES.base;
        if (currentIdx === this.strokes.length - 1) {
          this.dehighlightAll();
        }
      }, ANIMATION_CONFIG.stepDuration + 10);
      
      this.timers.push(timer);
      this.currentIndex++;
    } else {
      this.reset();
    }
  }

  /**
   * Toggle between brush and clean visual styles
   */
  toggleStyle() {
    const currentMode = this.el.dataset.style === 'brush' ? 'clean' : 'brush';
    
    this.el.dataset.style = currentMode;
    this.el.classList.toggle('brush', currentMode === 'brush');
    this.el.classList.toggle('clean', currentMode === 'clean');
    
    if (!this.strokes?.length) return;
    
    if (currentMode === 'clean') {
      this.applyCleanStyle();
    } else {
      this.applyBrushStyle();
    }
  }

  /**
   * Apply clean visual style (minimal)
   */
  applyCleanStyle() {
    this.strokes.forEach(path => {
      Object.assign(path.style, {
        filter: 'none',
        strokeWidth: '2.6',
        strokeLinecap: 'round',
        strokeLinejoin: 'round'
      });
    });
  }

  /**
   * Apply brush visual style (textured)
   */
  applyBrushStyle() {
    this.strokes.forEach(path => {
      Object.assign(path.style, {
        filter: SHADOW_STYLES.base,
        strokeWidth: (3 + Math.random() * 0.5).toFixed(2)
      });
    });
  }

  /**
   * Register LiveView event handlers
   */
  registerEvents(hookContext) {
    if (this.eventsRegistered) return;
    
    hookContext.handleEvent('stroke_order_restart', (payload) => {
      if (payload.kanji === this.el.dataset.kanji) {
        this.replay();
      }
    });
    
    hookContext.handleEvent('stroke_order_step', (payload) => {
      if (payload.kanji === this.el.dataset.kanji) {
        this.step();
      }
    });
    
    hookContext.handleEvent('stroke_order_toggle_style', (payload) => {
      if (payload.kanji === this.el.dataset.kanji) {
        this.toggleStyle();
      }
    });
    
    this.eventsRegistered = true;
  }
}

// Export as Phoenix LiveView Hook
export const KanjiStrokeOrderAnimate = {
  mounted() {
    this.animator = new StrokeOrderAnimator(this.el);
    this.animator.prepare();
    this.animator.registerEvents(this);
  },

  updated() {
    this.animator?.prepare();
  },

  destroyed() {
    this.animator?.clearTimers();
  }
};
