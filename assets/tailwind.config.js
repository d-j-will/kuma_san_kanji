// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/kuma_san_kanji_web.ex",
    "../lib/kuma_san_kanji_web/**/*.*ex"
  ],
  safelist: [
    'wabi-container',
    'wabi-paper',
    'wabi-texture',
    'wabi-text',
    'wabi-accent-text',
    'kanji-display',
    'kanji-container',
    'btn-wabi'
  ],
  theme: {
    extend: {      colors: {
        brand: "oklch(var(--p))",
        wabi: {
          // Base neutrals mapped to daisyUI base colors
          cream: "oklch(var(--b1))",
          stone: "oklch(var(--b2))",
          ecru: "oklch(var(--b3))",
          paper: "oklch(var(--b1))",
          shadow: "oklch(0% 0 0 / 0.1)",
          
          // Natural accent colors mapped to daisyUI semantic colors
          indigo: "oklch(var(--s))",      // Secondary
          rust: "oklch(var(--a))",        // Accent
          hok_blue: "oklch(var(--p))",    // Primary
          hok_blue_dark: "oklch(var(--p))", // Primary (simplify for now, or use darker if possible)
          clay: "oklch(var(--n))",        // Neutral
          charcoal: "oklch(var(--bc))",   // Base Content
          
          // Borders
          border: "oklch(var(--b3))",
          border_light: "oklch(var(--b2))",
          
          // Kanji specific - map to semantic for now
          'kanji-primary': "oklch(var(--p))",
          'kanji-accent': "oklch(var(--a))",
          'kanji-highlight': "oklch(var(--s))",
          'kanji-bg': "oklch(var(--b1))",
          'kanji-shadow': "oklch(var(--nc))",
          
          // Textured variants (simplified)
          'cream-dark': "oklch(var(--b2))",
          'stone-light': "oklch(var(--b2))",
          'paper-aged': "oklch(var(--b2))",
        },
        // Keep existing colors for backward compatibility
        accent: {
          blue: "oklch(var(--p))",
          pink: "oklch(var(--s))",
          purple: "oklch(var(--a))",
          green: "oklch(var(--su))",
          yellow: "oklch(var(--wa))",
        },
        sakura: {
          light: "oklch(var(--b2))",
          DEFAULT: "oklch(var(--s))",
          dark: "oklch(var(--s))",
          blossom: "oklch(var(--p))",
          white: "oklch(var(--b1))",
        }
      },      fontFamily: {
        'katakana': ['"Zen Maru Gothic"', '"M PLUS 1p"', 'sans-serif'],
        'display': ['"Stick"', '"Yuji Syuku"', 'monospace'],
        // Wabi-Sabi inspired fonts - all sans-serif
        'wabi': ['"Inter"', '"Noto Sans"', 'sans-serif'],
        'wabi-display': ['"Zen Maru Gothic"', '"M PLUS 1p"', 'sans-serif'],
        'brush': ['"Yuji Syuku"', '"Zen Antique Soft"', 'cursive'],
        // Set default font family to sans-serif
        'sans': ['"Inter"', '"Noto Sans"', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        'xs': ['0.8125rem', { lineHeight: '1.25rem' }],
        'sm': ['0.9375rem', { lineHeight: '1.375rem' }],
        'base': ['1.0625rem', { lineHeight: '1.625rem' }],
        'lg': ['1.1875rem', { lineHeight: '1.75rem' }],
        'xl': ['1.3125rem', { lineHeight: '1.875rem' }],
        '2xl': ['1.5625rem', { lineHeight: '2rem' }],
        '3xl': ['1.9375rem', { lineHeight: '2.375rem' }],
        '4xl': ['2.4375rem', { lineHeight: '2.75rem' }],
        '5xl': ['3.0625rem', { lineHeight: '3.25rem' }],
        '6xl': ['3.8125rem', { lineHeight: '4rem' }],
        '7xl': ['4.6875rem', { lineHeight: '4.75rem' }],
        '8xl': ['6.25rem', { lineHeight: '6.5rem' }],
        '9xl': ['8.125rem', { lineHeight: '8.5rem' }],
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("daisyui"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ],
  daisyui: {
    themes: [
      "light",
      "dark",
      "cupcake",
      "bumblebee",
      "emerald",
      "corporate",
      "synthwave",
      "retro",
      "cyberpunk",
      "valentine",
      "halloween",
      "garden",
      "forest",
      "aqua",
      "lofi",
      "pastel",
      "fantasy",
      "wireframe",
      "black",
      "luxury",
      "dracula",
      "cmyk",
      "autumn",
      "business",
      "acid",
      "lemonade",
      "night",
      "coffee",
      "winter",
      "dim",
      "nord",
      "sunset",
    ],
  }
}
