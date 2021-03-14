import AWN from 'awesome-notifications'
import { Point } from './src/types'
import NodeFactory from './src/node_factory'
import Sketch, { SketchConfig } from './src/sketch'
import WSclient from './src/ws_client'

import './src/styles.scss'
import './src/awn.scss'



// STATE
const skt_cfg: SketchConfig = {
  canvas_width: 700,
  canvas_height: 700,
  hashing_ring_origin: Point.from_coord(350, 350),
  hashing_ring_diameter: 300,
}


let p5 = undefined
let factory: NodeFactory = undefined
const awn = new AWN({ icons: { enabled: false } })



// ===============================================================
// SOCKET CALLBACKS
const open_cb = () => {
  const canvasContainerID = 'sketch'
  p5 = new (window as any).p5(Sketch(skt_cfg), canvasContainerID)
  factory = new NodeFactory(skt_cfg.hashing_ring_origin, skt_cfg.hashing_ring_diameter)
  awn.success("Connection established")
}


const message_cb = (event: any) => {
  const payload = JSON.parse(event.data)
  const { action, data } = payload
  awn.info(`Receiving \"${action.toUpperCase()}\" Event`)

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
}


const error_cb = (timeout: number) => {
  const msg = `Websocket error! Retry to connect in ${timeout / 1000} seconds`
  awn.alert(msg)
}


const ich_host = process.env.HOST || window.location.hostname
const url = "ws://" + ich_host + ":8081"
new WSclient(url, { open_cb, message_cb, error_cb })
