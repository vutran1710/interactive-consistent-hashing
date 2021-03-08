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
    sketch.draw = () => f(...args)
    sketch.redraw()
  }

  // NOTE: example drawing function for incremental drawing
  sketch.makeCircle = redraw(_ => {
    sketch.strokeWeight(1)
    sketch.stroke(0, 0, 0, 0.5)
    sketch.circle(500, 500, 300)
  })

  // TODO: implement actions based on events received
}


const objects = []
let p5 = undefined
const elementDrawSectionID = 'sketch'
const socket = new WebSocket('ws://localhost:8081')

socket.addEventListener('open', function(event) {
  const msg = { sender: "app" }
  socket.send(JSON.stringify(msg))
  p5 = new (window as any).p5(s, elementDrawSectionID)
  p5.makeCircle()
})

socket.addEventListener('message', function(event) {
  console.log(JSON.parse(event.data))
  // p5[event_info.type](event_info.data)
})
