import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  resolve: { preserveSymlinks: true },
  server: {
    host: '127.0.0.1',
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    // Phaser's isolated vendor chunk compresses to about 340 KB.
    chunkSizeWarningLimit: 1500,
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('/node_modules/phaser/')) return 'phaser';
        },
      },
    },
  },
});
