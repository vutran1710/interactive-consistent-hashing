import { Point } from './types'

/*
  Convert an angle(Degrees) to Point A's coordinates(X, Y) in a layout,
  with a given origin O and distance(radius) from the Point A to O
*/
export const angle_to_coord = (angle: number, radius: number, origin: Point, degree = true): Point => {
  let pi_angle = angle

  if (degree) {
    pi_angle = angle * Math.PI / 180
  }

  const x = radius * Math.cos(pi_angle) + origin.x
  const y = radius * Math.sin(pi_angle) + origin.y
  return Point.from_coord(x, y)
}

export const distance = (start: Point, end: Point): number => {
  const termx = (end.x - start.x) ** 2
  const termy = (end.y - start.y) ** 2
  return (termx + termy) ** 0.5
}

export const make_arc = (start: Point, end: Point, origin: Point, radius: number) => {
  const r = distance(start, end) * 0.5
  const a1 = Math.acos((start.x - origin.x) / radius)
  const a2 = Math.acos((end.x - origin.x) / radius)
  const a3 = (a1 + a2) / 2
  const mid_point = Point.from_coord((start.x + end.x) / 2, (start.y + end.y) / 2)
  const new_center = angle_to_coord(a3, radius + r, origin, false)

  if ((mid_point.y - origin.y) / (new_center.y - origin.y) < 0) {
    // Flip the center to the same side with start & end
    new_center.y = origin.y - Math.abs(new_center.y - origin.y)
  }

  const new_radius = distance(new_center, start)

  let arc_start = Math.acos((start.x - new_center.x) / new_radius)

  if (start.y < new_center.y) {
    arc_start = -arc_start
  }

  let arc_stop = Math.acos((end.x - new_center.x) / new_radius)

  if (end.y < new_center.y) {
    arc_stop = 2 * Math.PI - arc_stop
  }

  return {
    c: new_center,
    r: new_radius,
    start: arc_start,
    stop: arc_stop,
  }
}
