/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        accent:      'var(--accent)',
        'accent-2':  'var(--accent2)',
        'accent-dk': 'var(--accent-dark)',
        'accent-lt': 'var(--accent-light)',
        surface:     'var(--surface)',
        muted:       'var(--muted)',
        border:      'var(--border)'
      },
      fontFamily: {
        sans: ['Inter', 'Segoe UI', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Consolas', 'monospace']
      }
    }
  },
  plugins: []
};
