export const KanjiStrokeTracing = {
  mounted() {
    this.canvas = this.el;
    this.ctx = this.canvas.getContext('2d');
    this.drawing = false;
    this.lastPos = { x: 0, y: 0 };
    
    // Maintain SVG coordinate system (109x109)
    // but scale canvas resolution for sharpness if needed
    // For now, we trust the attribute width/height (109) matches the logical space
    
    this.bindEvents();
  },

  bindEvents() {
    // Mouse
    this.canvas.addEventListener('mousedown', this.start.bind(this));
    this.canvas.addEventListener('mousemove', this.draw.bind(this));
    this.canvas.addEventListener('mouseup', this.stop.bind(this));
    this.canvas.addEventListener('mouseleave', this.stop.bind(this));
    
    // Touch
    this.canvas.addEventListener('touchstart', (e) => {
      e.preventDefault(); 
      const touch = e.touches[0];
      const rect = this.canvas.getBoundingClientRect();
      this.start({ clientX: touch.clientX, clientY: touch.clientY, rect: rect });
    }, { passive: false });
    
    this.canvas.addEventListener('touchmove', (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      const rect = this.canvas.getBoundingClientRect();
      this.draw({ clientX: touch.clientX, clientY: touch.clientY, rect: rect });
    }, { passive: false });

    this.canvas.addEventListener('touchend', (e) => {
       this.stop();
    });
  },

  getPos(e) {
    // If rect passed explicitly (touch), use it, otherwise get fresh
    const rect = e.rect || this.canvas.getBoundingClientRect();
    
    // Scale logic: Map client coordinates to canvas internal dimensions (109x109)
    const scaleX = this.canvas.width / rect.width;
    const scaleY = this.canvas.height / rect.height;
    
    return {
      x: (e.clientX - rect.left) * scaleX,
      y: (e.clientY - rect.top) * scaleY
    };
  },

  start(e) {
    this.drawing = true;
    this.lastPos = this.getPos(e);
  },

  draw(e) {
    if (!this.drawing) return;
    const pos = this.getPos(e);
    
    this.ctx.beginPath();
    this.ctx.lineWidth = 3; 
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';
    // Use a high-contrast color that works well on both light/dark themes
    // Using a semi-transparent cyan/blue to overlay on black strokes
    this.ctx.strokeStyle = 'rgba(0, 200, 255, 0.6)'; 
    
    this.ctx.moveTo(this.lastPos.x, this.lastPos.y);
    this.ctx.lineTo(pos.x, pos.y);
    this.ctx.stroke();
    
    this.lastPos = pos;
  },

  stop() {
    this.drawing = false;
  }
};
