import { fusebox, pluginSass } from 'fuse-box'

const fuse = fusebox({
  entry: 'index.ts',
  target: 'browser',
  plugins: [pluginSass()],
  devServer: true,
  webIndex: {
    template: "index.html",
  },
})

fuse.runDev()
