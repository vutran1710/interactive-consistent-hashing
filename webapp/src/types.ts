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

export interface Record {
  id: number
  name: string
}

export interface Hash {
  0: number
  1: number
  2: number
  4: string
}

export interface GetRecordData {
  record?: Record
  hash: Hash
}


export class HashObject {
  id: number
  hashed: number
  cache_angle: number
  cache_id: string

  constructor(data: Hash) {
    this.id = data[0]
    this.hashed = data[1]
    this.cache_angle = data[2]
    this.cache_id = data[3]
  }
}
