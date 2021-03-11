import { Point } from './types'


export const angle_to_coord = (angle: number, radius: number, origin: Point): Point => {
  const pi_angle = angle * Math.PI / 180
  const x = radius * Math.sin(pi_angle) + origin.x
  const y = radius * Math.cos(pi_angle) + origin.y
  return Point.from_coord(x, y)
}
