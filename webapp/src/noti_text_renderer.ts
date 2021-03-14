export const WS_OPEN = "WebSocket connection established"
export const WS_MESSAGE = (action: string) => `Receiving \"${action.toUpperCase()}\" Event`
export const WS_ERROR = (timeout: number) => `Websocket error! Retry to connect in ${timeout / 1000} seconds`
