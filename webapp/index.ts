const socket = new WebSocket('ws://localhost:8081')

socket.addEventListener('open', function(event) {
  const msg = { sender: "app" }
  socket.send(JSON.stringify(msg))
})

socket.addEventListener('message', function(event) {
  console.log('Message from server ', event.data)
})

socket.addEventListener('close', function(event) {
  console.log('The connection has been closed')
})
