export class Point {
  x: number
  y: number

  constructor(x: number, y: number) {
    this.x = x
    this.y = y
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
  3: string
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


export class Node {
  label: string
  angle: number
  server: string
  online: boolean
  color: string
}


export interface SketchConfig {
  canvas_width: number
  canvas_height: number
  hashing_ring_origin: Point
  hashing_ring_diameter: number
}


export interface WScallbacks {
  open_cb: Function
  error_cb: Function
  message_cb: Function
}
