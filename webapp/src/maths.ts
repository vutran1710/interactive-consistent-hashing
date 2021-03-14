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
  return new Point(x, y)
}


/*
  Distance between two Points
*/
export const distance = (start: Point, end: Point): number => {
  const termx = (end.x - start.x) ** 2
  const termy = (end.y - start.y) ** 2
  return (termx + termy) ** 0.5
}


/*
  From 2 points: Start & End, the Origin and the Radius of the Hashing Ring
  We have to draw an arc for P5JS to execute with arc() function
*/
export const make_arc = (start: Point, end: Point, origin: Point, radius: number) => {
  const r = distance(start, end) / 4

  const start_angle = Math.acos((start.x - origin.x) / radius)
  const end_angle = Math.acos((end.x - origin.x) / radius)
  const mid_angle = (start_angle + end_angle) / 2

  const mid_point = new Point((start.x + end.x) / 2, (start.y + end.y) / 2)
  const arc_center = angle_to_coord(mid_angle, radius + r, origin, false)

  if ((mid_point.y - origin.y) / (arc_center.y - origin.y) < 0) {
    // Flip the arc-center to the same side with start & end
    // meaning, the arc-center must stay out of the Ring
    arc_center.y = origin.y - Math.abs(arc_center.y - origin.y)
  }

  const arc_radius = distance(arc_center, start)

  let arc_start_angle = Math.acos((start.x - arc_center.x) / arc_radius)

  if (start.y < arc_center.y) {
    arc_start_angle = -arc_start_angle
  }

  let arc_stop_angle = Math.acos((end.x - arc_center.x) / arc_radius)

  if (end.y < arc_center.y) {
    arc_stop_angle = 2 * Math.PI - arc_stop_angle
  }

  return {
    c: arc_center,
    r: arc_radius,
    start: arc_start_angle,
    stop: arc_stop_angle,
  }
}
