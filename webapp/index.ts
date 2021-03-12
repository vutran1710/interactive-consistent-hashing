import { Point } from './src/types'
import { angle_to_coord, make_arc_points } from './src/maths'
import { Node, NodeFactory } from './src/node_factory'

const origin = Point.from_coord(300, 300)
const diameter = 400
const circumference = Math.PI * diameter


const p5_sketch = (s: any) => {
  s.setup = () => {
    s.createCanvas(800, 800)
    s.noLoop()
  }

  s.draw = () => undefined

  const redraw = (f: Function) => (...args: any[]) => {
    s.draw = () => f(...args)
    s.redraw()
  }

  s.pin_points = redraw((nodes: Node[]) => {
    const radius = diameter / 2
    const online_node_dim = Math.min(circumference / (3 * nodes.length), 20)
    const offline_node_dia = Math.min(circumference / (4 * nodes.length), online_node_dim)

    nodes.forEach(node => {
      // Point
      const coord = angle_to_coord(node.angle, radius, origin)
      if (!node.online) {
	s.strokeWeight(1)
	s.stroke("#ddd")
	s.fill('white')
	s.circle(coord.x, coord.y, offline_node_dia)
      } else {
	s.stroke(node.color)
	s.strokeWeight(online_node_dim)
	s.point(coord.x, coord.y)
      }
      // Label
      const extended = radius * 1.2
      const txt_coord = angle_to_coord(node.angle, extended, origin)
      s.fill(node.online ? 'black' : 'white')
      s.stroke(0, 0, 0, 0)
      s.textAlign(s.CENTER)
      s.text(node.label, txt_coord.x, txt_coord.y)
    })
  })

  s.make_circle = redraw(() => {
    s.strokeWeight(2)
    s.stroke('#cfd2e6')
    s.circle(origin.x, origin.y, diameter)
  })

  s.draw_arc = redraw((points: Point[]) => {
    // start-point
    const record = points[0]
    s.stroke('red')
    s.strokeWeight(10)
    s.point(record.x, record.y)
    // cache-point
    const cache = points[1]
    s.stroke('blue')
    s.strokeWeight(10)
    s.point(cache.x, cache.y)
    // arc
    const ps = make_arc_points(record, cache, origin, diameter / 2)
    s.strokeWeight(1)
    s.stroke('red')
    s.noFill()
    s.arc(ps.c.x, ps.c.y, ps.r * 2, ps.r * 2, ps.start, ps.stop, s.OPEN)
    // console.log("=============> ", p)
    // s.point(p.center.x, p.center.y)
    // s.fill(0, 0, 0, 0)
    // s.circle(p.center.x, p.center.y, p.radius)
  })

  s.on_open = s.make_circle
  s.on_new = s.pin_points
  s.on_get = s.draw_arc
}


let p5 = undefined
const canvasContainerID = 'sketch'
let factory: NodeFactory = undefined
const socket = new WebSocket('ws://localhost:8081')

socket.onopen = () => {
  const msg = { sender: Math.random() }
  socket.send(JSON.stringify(msg))
  p5 = new (window as any).p5(p5_sketch, canvasContainerID)
}

socket.onerror = () => socket.close()


socket.onmessage = event => {
  const payload = JSON.parse(event.data)
  console.log("Received=", payload)
  const { action, data } = payload
  const draw = p5[`on_${action}`]

  if (action == "new") {
    if (!factory) factory = new NodeFactory(data.id, origin, diameter)
    p5.clear()
    p5.fill('white')
    p5.on_open()
    const nodes = factory.on_new(data.table)
    draw(nodes)
  }

  if (action == "get") {
    const points = factory.on_get(data)
    if (!points.length) return undefined
    draw(points)
  }
}
