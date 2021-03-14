import { fusebox, pluginSass } from 'fuse-box'

const is_prod = process.env.NODE_ENV == 'prod'

const fuse = fusebox({
  entry: 'index.ts',
  target: 'browser',
  plugins: [pluginSass()],
  sourceMap: false,
  devServer: !is_prod,
  webIndex: {
    template: "index.html",
  },

})

const mode = is_prod ? 'runProd' : 'runDev'

const bundle_config = {
  bundles: {
    app: 'app.js'
  }
}

fuse[mode](bundle_config)
