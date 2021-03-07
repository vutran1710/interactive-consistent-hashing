const s = sketch => {
  sketch.setup = () => {
    sketch.createCanvas(1000, 1000)
    sketch.noLoop()
  }

  sketch.draw = () => {
    sketch.background('#ddd')
    sketch.fill(255)
  }

  const redraw = (f: Function) => (...args: any[]) => {
    sketch.draw = f(...args)
    sketch.redraw()
  }

  // NOTE: example drawing function for incremental drawing
  sketch.makeCircle = redraw((rad: number, color: string) => () => {
    sketch.strokeWeight(1)
    sketch.fill(color || 'red')
    sketch.circle(2 * rad, 3 * rad, rad)
  })

  // TODO: implement actions based on events received
}


let p5 = undefined
const elementDrawSectionID = 'sketch'
const socket = new WebSocket('ws://localhost:8081')

socket.addEventListener('open', function(event) {
  const msg = { sender: "app" }
  socket.send(JSON.stringify(msg))
  p5 = new (window as any).p5(s, elementDrawSectionID)
})

socket.addEventListener('message', function(event) {
  const event_info = JSON.parse(event.data)
  p5[event_info.type](event_info.data)
})
