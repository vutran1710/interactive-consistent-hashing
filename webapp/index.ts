const {
  createCanvas,
  mouseIsPressed,
  fill,
  ellipse,
  mouseX,
  mouseY,
} = window.p5


const setup = () => createCanvas(400, 400)

const draw = () => {
  if (mouseIsPressed) {
    fill(0)
  } else {
    fill(255)
  }
  ellipse(mouseX, mouseY, 80, 80)
}


setup()
draw()
