import { Point } from './types'

/*
  Convert an angle(Degrees) to Point A's coordinates(X, Y) in a layout,
  with a given origin O and distance(radius) from the Point A to O
 */
export const angle_to_coord = (angle: number, radius: number, origin: Point): Point => {
  const pi_angle = angle * Math.PI / 180
  const x = radius * Math.cos(pi_angle) + origin.x
  const y = radius * Math.sin(pi_angle) + origin.y
  return Point.from_coord(x, y)
}
