import distinctColors from 'distinct-colors'

export class Node {
  label: string
  angle: number
  server: string
  online: boolean
  color: string
}


export class NodeFactory {

  palette: any

  constructor(server_ids: string[]) {
    const count = server_ids.length
    const colors = distinctColors({ count })
    this.palette = server_ids.reduce((palette, id, idx) => ({
      ...palette,
      [id]: colors[idx].name()
    }), {})
  }

  produce_nodes(point_data: any[]): Array<Node> {
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
}



export class Point {
  x: number
  y: number

  static from_coord(x: number, y: number): Point {
    const p = new Point()
    p.x = x
    p.y = y
    return p
  }
}
