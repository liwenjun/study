import { defineConfig } from "vite"
import elmPlugin from "vite-plugin-elm"
// import viteCompression from 'vite-plugin-compression'

export default defineConfig({
  //  plugins: [elmPlugin({ debug: false, optimize: true })],
  plugins: [
  //  viteCompression({
  //    algorithm: 'brotliCompress'
  //  }),
    elmPlugin(),
  ],
})
