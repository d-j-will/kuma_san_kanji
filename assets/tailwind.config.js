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
  theme: {
    extend: {      colors: {
        brand: "oklch(63.5% 0.25 31)",        // Wabi-Sabi inspired natural color palette in oklch format
        wabi: {
          // Base neutrals - weathered and natural
          cream: "oklch(96% 0.015 85)",        // Weathered cream
          stone: "oklch(85% 0.012 75)",        // Stone gray
          ecru: "oklch(95% 0.010 80)",         // Gentle ecru
          paper: "oklch(98% 0.008 85)",        // Handmade paper
          shadow: "oklch(0% 0 0 / 0.08)",      // Subtle shadows
          
          // Natural accent colors
          indigo: "oklch(38% 0.025 250)",      // Natural indigo
          rust: "oklch(45% 0.08 35)",          // Rust/clay
          moss: "oklch(48% 0.05 120)",         // Moss green
          clay: "oklch(50% 0.06 55)",          // Clay brown
          charcoal: "oklch(25% 0.015 250)",    // Sumi ink black
          
          // Textured variants
          'cream-dark': "oklch(93% 0.018 80)",
          'stone-light': "oklch(88% 0.010 75)",
          'paper-aged': "oklch(96% 0.012 82)",
        },
        // Keep existing colors for backward compatibility
        accent: {
          blue: "oklch(55% 0.1 250)",     // Muted blue
          pink: "oklch(75% 0.1 350)",     // Soft pink
          purple: "oklch(60% 0.1 300)",   // Muted purple
          green: "oklch(75% 0.1 150)",    // Muted green
          yellow: "oklch(85% 0.1 90)",    // Soft yellow
        },
        sakura: {
          light: "oklch(95% 0.03 350)",   // Very light pink
          DEFAULT: "oklch(85% 0.08 350)", // Medium pink
          dark: "oklch(70% 0.12 350)",    // Darker pink
          blossom: "oklch(80% 0.1 5)",    // Blossom pink
          white: "oklch(98% 0.01 350)",   // Off-white
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
  ]
}
