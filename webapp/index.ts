import { Point } from './src/types'
import NodeFactory from './src/node_factory'
import Sketch, { SketchConfig } from './src/sketch'
import './src/styles.scss'

const config: SketchConfig = {
  canvas_width: 700,
  canvas_height: 700,
  hashing_ring_origin: Point.from_coord(350, 350),
  hashing_ring_diameter: 300,
}


let p5 = undefined
let factory: NodeFactory = undefined

const ichHost = process.env.HOST || window.location.hostname
const canvasContainerID = 'sketch'
const url = "ws://" + ichHost + ":8081"
console.info("WS Url=", url)
const socket = new WebSocket(url)


socket.onopen = () => {
  const msg = { sender: Math.random().toString() }
  console.log(msg)
  socket.send(JSON.stringify(msg))
  p5 = new (window as any).p5(Sketch(config), canvasContainerID)
  factory = new NodeFactory(config.hashing_ring_origin, config.hashing_ring_diameter)
}


socket.onerror = () => socket.close()


socket.onmessage = event => {
  const payload = JSON.parse(event.data)
  console.log("Received=", payload)
  const { action, data } = payload

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
