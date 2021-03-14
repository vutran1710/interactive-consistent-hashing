export interface WScallbacks {
  open_cb: Function
  error_cb: Function
  message_cb: Function
}


export default class WSclient {
  _s: WebSocket
  _url: string

  callbacks: WScallbacks
  retry = 2

  constructor(url: string, callbacks: WScallbacks) {
    this._url = url
    this.callbacks = callbacks
    this.init_conn()
  }

  init_conn = () => {
    this._s = new WebSocket(this._url)
    this._s.onerror = this.on_error
    this._s.onopen = this.on_open
    this._s.onmessage = this.on_message
  }

  retry_conn = () => {
    this.init_conn()
    this.retry *= 2
  }

  on_error = () => {
    const timeout = this.retry * 1000
    setTimeout(this.retry_conn, timeout)
    this.callbacks.error_cb(timeout)
  }

  on_open = () => {
    const msg = { sender: Math.random().toString() }
    console.log(msg)
    this._s.send(JSON.stringify(msg))
    this.callbacks.open_cb(msg)
  }

  on_message = (e: any) => {
    this.callbacks.message_cb(e)
  }
}
