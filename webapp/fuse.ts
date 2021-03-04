import { fusebox } from 'fuse-box'

const fuse = fusebox({
  entry: 'index.ts',
  target: 'browser',
  devServer: true,
  webIndex: {
    template: "index.html",
  },
})

fuse.runDev()
