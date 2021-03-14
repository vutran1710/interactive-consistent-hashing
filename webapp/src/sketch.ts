import { angle_to_coord, make_arc } from './maths'
import { Point, Node } from './types'


export interface SketchConfig {
  canvas_width: number
  canvas_height: number
  hashing_ring_origin: Point
  hashing_ring_diameter: number
}


const Sketch = ({
  canvas_width,
  canvas_height,
  hashing_ring_origin: origin,
  hashing_ring_diameter: diameter,
}: SketchConfig) => (s: any) => {

  const circumference = Math.PI * diameter

  s.setup = () => {
    s.createCanvas(canvas_height, canvas_width)
    s.noLoop()
  }

  s.draw = () => undefined

  const redraw = (f: Function) => (...args: any[]) => {
    // NOTE: a bootstrapping function that enable p5js incremental-drawing
    s.draw = () => f(...args)
    s.redraw()
  }

  s.make_circle = redraw(() => {
    s.strokeWeight(1)
    s.stroke('LightSkyBlue')
    s.circle(origin.x, origin.y, diameter)
  })

  s.pin_points = redraw((nodes: Node[]) => {
    const radius = diameter / 2
    const online_node_d = Math.min(circumference / (3 * nodes.length), 20)
    const offline_node_d = Math.min(circumference / (4 * nodes.length), online_node_d)

    nodes.forEach(node => {
      // Point
      const coord = angle_to_coord(node.angle, radius, origin)
      if (!node.online) {
	s.strokeWeight(1)
	s.stroke("#ddd")
	s.fill('white')
	s.circle(coord.x, coord.y, offline_node_d)
      } else {
	s.stroke(node.color)
	s.strokeWeight(online_node_d)
	s.point(coord.x, coord.y)
      }
      // Label
      const extended = radius * 1.2
      const txt_coord = angle_to_coord(node.angle, extended, origin)
      s.fill(node.online ? 'black' : '#ddd')
      s.stroke(0, 0, 0, 0)
      s.textAlign(s.CENTER)
      s.text(node.label, txt_coord.x, txt_coord.y)
    })
  })

  s.draw_arc = redraw((points: Point[]) => {
    // start-point
    const record = points[0]
    s.stroke('red')
    s.strokeWeight(10)
    s.point(record.x, record.y)
    // cache-point
    const cache = points[1]
    s.stroke('royalblue')
    s.strokeWeight(10)
    s.point(cache.x, cache.y)
    // arc
    const ps = make_arc(record, cache, origin, diameter / 2)
    s.strokeWeight(1)
    s.stroke('#ff5f958a')
    s.noFill()
    s.arc(ps.c.x, ps.c.y, ps.r * 2, ps.r * 2, ps.start, ps.stop, s.OPEN)
  })

}

export default Sketch
