import * as ipc from 'node-ipc'
import {Socket} from 'net'
import {Window} from "./window"

// class Message {
//   type : string
//   data : object | null

//   constructor(type : string, data : any) {
//     this.type = type
//     this.data = data
//   }
// }

export let ClientMessages = {
  CONNECT: "connect",
  DISCONNECT: "socket.disconnect",
  QUIT: "quit"
}

export let ClientCommands = {
  GOTO: "goto",
  SCREENSHOT: "screenshot",
  QUIT: "quit"
}

export let ServerMessages = {
  SCREENSHOT: "screenshot",
  READY: "ready"
}

export class Server {
  clients : Array<Socket> // FIXME change to single client?
  window : Window
  window_ready : boolean

  constructor() {
    this.clients = []
    this.window_ready = false
    this.window = new Window
    this.registerWindowEvents(this.window)
    this.createServer()
  }

  registerWindowEvents(window : Window) {
    window.window.on("ready-to-show", (event : Event) => {
      this.window_ready = true
      setTimeout(() => {
        this.window.screenshot("comparison.png", () => {})
      }, 1000)
      this.emit(ServerMessages.READY)
    })
  }

  createServer() {
    ipc.config.id    = 'stoertebeker'
    // ipc.config.retry = 5

    this.registerMessages()
  }

  start() {
    ipc.server.start()
  }

  registerMessages() {
    this.onCommand = this.onCommand.bind(this)
    this.onConnect = this.onConnect.bind(this)
    this.onDisconnect = this.onDisconnect.bind(this)

    ipc.serve(
      () => {
        //ipc.server.on("command", this.onCommand)

        ipc.server.on("command",
          (data : any, socket : Socket) => {
            console.log(data)
            this.onCommand(data, socket)
          }
        )

        ipc.server.on(ClientMessages.CONNECT, this.onConnect)

        ipc.server.on(ClientMessages.DISCONNECT, this.onDisconnect)

        ipc.server.on(
          ClientMessages.QUIT,
          (data : string, socket : Socket) => {
            ipc.log('Received: QUIT')
            this.window.close()
          }
        )
      }
    )
  }

  onConnect(socket : Socket) {
    this.logSignal(ClientMessages.CONNECT)

    this.clients.push(socket)

    // if(this.window_ready) {
    //   ipc.server.emit(socket, 'ready')
    // }
  }

  onDisconnect(socket : Socket, destroyedSocketID : string) {
    this.logSignal(ClientMessages.DISCONNECT)

    const index = this.clients.indexOf(socket, 0)

    this.clients.splice(index, 1)
  }

  onCommand(data : any, socket : Socket) {
    this.logSignal(`cmd ${data.type}`)

    switch(data.type) {
      case ClientCommands.GOTO: {
        this.window_ready = false
        console.log(`GOTO ${data.url}`)
        this.window.loadUrl(data.url)
        break
      }
      case ClientCommands.SCREENSHOT: {
        this.window.screenshot(data.filename, () => {
          ipc.server.emit(socket, ServerMessages.SCREENSHOT)
        })
        break
      }
      case ClientCommands.QUIT: {
        ipc.log('Received: QUIT')
        this.window.close()
        break
      }
      default: {
        ipc.log(`UNHANDLED COMMAND: ${data.type}`)
        break
      }
    }
  }

  emit(message : string) {
    this.clients.forEach((c) => {
      ipc.server.emit(c, message)
    })
  }

  logSignal(str : string) {
    ipc.log(`RECEIVED: ${str}`)
  }
}

