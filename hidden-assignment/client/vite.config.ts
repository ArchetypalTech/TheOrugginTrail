import { defineConfig } from 'vite'
import path from 'path';
import dts from 'vite-plugin-dts'



// https://vitejs.dev/config/
export default defineConfig(({ mode, command }) => {
    return {
      base: './',
      test: {
        globals: true,
        environment: 'jsdom',
      },
      optimizeDeps: {
        esbuildOptions: {
          target: 'esnext'
        }
      },
      plugins: [dts({ rollupTypes: true })],
      build: {
        rollupOptions: {
          external: ['@noir-lang/noir_js', '@noir-lang/backend_barretenberg', '@noir-lang/types']
        },
        sourcemap: true,
        target: 'esnext',
        lib: {
          entry: path.resolve(__dirname, 'src/index.ts'),
          name: 'hidden-assignment',
          fileName: (format) => `hidden-assignment.${format}.js`
        }
      }
    }
});

