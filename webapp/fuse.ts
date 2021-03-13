import { fusebox, pluginSass } from 'fuse-box'

const is_prod = process.env.NODE_ENV == 'prod'

const fuse = fusebox({
  entry: 'index.ts',
  target: 'browser',
  plugins: [pluginSass()],
  devServer: !is_prod,
  webIndex: {
    template: "index.html",
  },
})

const mode = is_prod ? 'runProd' : 'runDev'

fuse[mode]()
