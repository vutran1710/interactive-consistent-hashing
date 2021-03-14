import AWN from 'awesome-notifications'
import { Point, SketchConfig, WScallbacks } from './src/types'
import NodeFactory from './src/node_factory'
import * as Txt from './src/noti_text_renderer'
import Sketch from './src/sketch'
import WSclient from './src/ws_client'
import './src/styles/index.scss'



const cfg: SketchConfig = {
  canvas_width: 700,
  canvas_height: 700,
  hashing_ring_origin: new Point(350, 350),
  hashing_ring_diameter: 300,
}

let p5 = undefined
let factory: NodeFactory = undefined

const awn = new AWN({ icons: { enabled: false } })
const ws_url = "ws://localhost:8081"


const ws_cb: WScallbacks = {
  open_cb: () => {
    const canvasContainerID = 'sketch'
    p5 = new (window as any).p5(Sketch(cfg), canvasContainerID)
    factory = new NodeFactory(cfg.hashing_ring_origin, cfg.hashing_ring_diameter)
    awn.success(Txt.WS_OPEN)
  },

  message_cb: (event: any) => {
    const payload = JSON.parse(event.data)
    const { action, data } = payload
    awn.info(Txt.WS_MESSAGE(action))

    if (action == "new") {
      p5.clear()
      p5.fill('white')
      p5.make_circle()
      const nodes = factory.on_new(data.table)
      p5.pin_points(nodes)
    }

    if (action == "get") {
      const points = factory.on_get(data)
      if (!points.length) return undefined
      p5.draw_arc(points)
    }
  },

  error_cb: Txt.WS_ERROR,
}

new WSclient(ws_url, ws_cb)
