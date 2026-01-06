import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    tailwindcss(),
    react({
      babel: {
        plugins: [['babel-plugin-react-compiler']],
      },
    }),
  ],
  server: {
    proxy: {
      "/api": {
        target: "http://slothz.ddns.net:22021",
        changeOrigin: true,
        secure: true,
        rewrite: (path) => path,
      },
    },
  },
});
