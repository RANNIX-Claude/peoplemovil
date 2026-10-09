import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg'],
      manifest: {
        name: 'PeopleMovil — Portal Freelance',
        short_name: 'PeopleMovil',
        description: 'Bolsa de trabajo y confirmación de eventos para colaboradores freelance de PeopleMovil.',
        start_url: '/portal/publicaciones',
        scope: '/',
        display: 'standalone',
        background_color: '#F5F5F7',
        theme_color: '#7B5EA7',
        icons: [
          { src: '/icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png' },
          { src: '/icons/icon-512-maskable.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' }
        ]
      },
      workbox: {
        // El admin interno y el portal público de vacantes comparten este mismo
        // build -- el service worker solo navega offline el shell SPA, nunca
        // cachea respuestas de Supabase (datos siempre en vivo).
        navigateFallbackDenylist: [/^\/admin/, /^\/vacantes/, /^\/postularme/],
        globPatterns: ['**/*.{js,css,html,svg,png,ico}']
      }
    })
  ],
  server: { port: Number(process.env.PORT) || 5173 },
  build: { outDir: 'dist', sourcemap: true }
});
