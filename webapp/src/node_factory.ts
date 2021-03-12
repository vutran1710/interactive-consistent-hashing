import distinctColors from 'distinct-colors'
import { GetRecordData, HashObject, Point, Node } from './types'
import { angle_to_coord } from './maths'


export default class NodeFactory {
  palette: any
  origin: Point
  diameter: number
  radius: number

  constructor(origin: Point, diameter: number) {
    this.origin = origin
    this.diameter = diameter
    this.radius = diameter / 2
  }

  init_color_palette(server_ids: string[]) {
    const colors = distinctColors({ count: server_ids.length })
    this.palette = {}
    server_ids.forEach((id, idx) => this.palette[id] = colors[idx].name())
  }

  on_new(point_data: any[]): Array<Node> {
    const server_ids = Array.from(new Set(point_data.map(p => p[2])))
    this.init_color_palette(server_ids)
    return point_data.map(point => {
      const [label, angle, server_id, online] = point
      const n = new Node()
      n.label = label
      n.angle = angle
      n.server = server_id
      n.color = this.palette[server_id]
      n.online = online
      return n
    })
  }

  on_get(data: GetRecordData): Array<Point> {
    if (!data.record) return []
    const hash_data = new HashObject(data.hash)
    const record_point = angle_to_coord(hash_data.hashed, this.radius, this.origin)
    const cache_point = angle_to_coord(hash_data.cache_angle, this.radius, this.origin)
    return [record_point, cache_point]
  }
}
