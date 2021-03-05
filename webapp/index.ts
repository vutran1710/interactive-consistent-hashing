import { io } from "socket.io-client"

const p5 = window.p5

const s = sketch => {

  let x = 100
  let y = 100

  sketch.setup = () => {
    sketch.createCanvas(200, 200)
  }

  sketch.draw = () => {
    sketch.background(0)
    sketch.fill(255)
    sketch.rect(x, y, 50, 50)
  }
}

new p5(s)
