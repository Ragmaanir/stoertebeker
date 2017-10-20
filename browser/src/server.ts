import * as ipc from 'node-ipc'
import {Socket} from 'net'
import {Window} from "./window"

// const electron = require('electron')
// const ConsoleMessageEvent = electron.ConsoleMessageEvent

//const {ipcMain} = require('electron')

export let ClientMessages = {
  CONNECT: "connect",
  DISCONNECT: "socket.disconnect"
}

export let ClientCommands = {
  WINDOW: "window",
  GOTO: "goto",
  WAIT: "wait",
  EVALUATE: "evaluate",
  SCREENSHOT: "screenshot",
  QUIT: "quit",
  PING: "ping"
}

export let ServerMessages = {
  WINDOW: "window",
  WAIT_SUCCESS: "wait_success",
  WAIT_FAILURE: "wait_failure",
  EVALUATE: "evaluate",
  SCREENSHOT: "screenshot",
  STATUS: "status",
  READY: "ready",
  RESOURCE: "resource",
  COMPLETED: "completed",
  PONG: "pong"
}

export class Server {
  clients : Array<Socket> // FIXME change to single client?
  window : Window
  window_ready : boolean
  loading : boolean

  constructor() {
    this.clients = []
    this.window_ready = false
    this.loading = false
    this.window = new Window
    this.registerEvents(this.window)
    this.createServer()
  }

  registerEvents(window : Window) {
    window.window.on("ready-to-show", (event : Event) => {
      this.window_ready = true
      if(this.loading) {
        this.emit(ServerMessages.READY)
        this.loading = false
      }
    })

    window.window.webContents.on("did-finish-load", () => {
      if(this.loading) {
        this.emit(ServerMessages.STATUS, {status: 200})
      }
    })

    // window.window.webContents.on("did-get-response-details", (event: Event,
    //                                                  status: boolean,
    //                                                  newURL: string,
    //                                                  originalURL: string,
    //                                                  httpResponseCode: number,
    //                                                  requestMethod: string,
    //                                                  referrer: string,
    //                                                  headers: any,
    //                                                  resourceType: string) => {
    //   this.emit(ServerMessages.RESOURCE, {
    //     status: httpResponseCode,
    //     url: newURL,
    //     originalURL: originalURL
    //   })
    // })

    window.window.webContents.on("did-stop-loading", (event: Event,
                                                     status: boolean,
                                                     newURL: string,
                                                     originalURL: string,
                                                     httpResponseCode: number,
                                                     requestMethod: string,
                                                     referrer: string,
                                                     headers: any,
                                                     resourceType: string) => {
      if(this.loading) {
        this.emit(ServerMessages.COMPLETED, {
          status: httpResponseCode,
          url: newURL,
          originalURL: originalURL
        })
      }
    })

    window.window.webContents.on("did-fail-load", (event: Event,
                                          errorCode: number,
                                          errorDescription: string,
                                          validatedURL: string,
                                          isMainFrame: boolean) => {
      this.emit(ServerMessages.STATUS, {status: errorCode, message: errorDescription, url: validatedURL})
    })

    // window.window.webContents.on('console-message', (event: typeof ConsoleMessageEvent) => {
    //   this.emit(ServerMessages.WAIT_SUCCESS)
    // })
  }

  createServer() {
    let dir = "../temp/"

    if(dir = process.env.SOCKET_DIR) {
      dir = dir+"/"
    }

    ipc.config.id    = 'stoertebeker'
    console.log("Socket Dir: "+dir)
    ipc.config.socketRoot = dir
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
        ipc.server.on("command", this.onCommand)

        ipc.server.on(ClientMessages.CONNECT, this.onConnect)

        ipc.server.on(ClientMessages.DISCONNECT, this.onDisconnect)
      }
    )
  }

  onConnect(socket : Socket) {
    this.logSignal(ClientMessages.CONNECT)

    this.clients.push(socket)
  }

  onDisconnect(socket : Socket, destroyedSocketID : string) {
    this.logSignal(ClientMessages.DISCONNECT)

    const index = this.clients.indexOf(socket, 0)

    this.clients.splice(index, 1)
  }

  onCommand(data : any, socket : Socket) {
    this.logSignal(`cmd ${data.type}`)

    switch(data.type) {
      case ClientCommands.PING: {
        this.emit(ServerMessages.PONG)
        break
      }
      case ClientCommands.WINDOW: {
        this.window.setSize(data.width, data.height)
        this.emit(ServerMessages.WINDOW)
        break
      }
      case ClientCommands.GOTO: {
        this.window_ready = false
        // FIXME: somehow electron fails to load urls prefixed with http://
        //const location = data.url.match("((.*)://)?(.*)")[3]
        //this.window.loadUrl(location)
        this.loading = true
        this.window.loadUrl(data.url)
        break
      }
      case ClientCommands.WAIT: {
        const selector = data.selector
        let tries = 0
        const delay = data.delay
        const max_tries = data.tries

        const callback = () => {
          this.window.evaluateScript(`document.querySelector("${selector}")`, (result : any) => {
            if(result != null) {
              // this.waitForPaint(() => {
              //   this.emit(ServerMessages.WAIT_SUCCESS)
              // })

              this.emit(ServerMessages.WAIT_SUCCESS)
            } else {
              if(tries < max_tries) {
                tries++
                this.wait(delay, callback)
              } else {
                this.window.evaluateScript(`document.body.innerHTML`, (result : any) => {
                  ipc.log(result.toString())
                  this.emit(ServerMessages.WAIT_FAILURE, {body: result})
                })
              }
            }
          })
        }

        callback()

        break
      }
      case ClientCommands.EVALUATE: {
        this.window.evaluateScript(data.script, (result : any) => {
          this.emit(ServerMessages.EVALUATE, result)
        })
        break
      }
      case ClientCommands.SCREENSHOT: {
        this.window.screenshot(data.filename, () => {
          this.emit(ServerMessages.SCREENSHOT)
        })
        break
      }
      case ClientCommands.QUIT: {
        this.window.close()
        break
      }
      default: {
        ipc.log(`UNHANDLED COMMAND: ${data.type}`)
        break
      }
    }
  }

  emit(type : string, data? : object) {
    this.clients.forEach((c) => {
      ipc.server.emit(c, type, data)
    })
  }

  wait(ms : number, callback : ()=>void ) {
    setTimeout(callback, ms)
  }

  // waitForPaint(callback : () => void) {
  //   const script = `
  //     var ipc = require('electron').ipcRenderer;

  //     window.requestAnimationFrame(function(){
  //       window.requestAnimationFrame(function(){
  //         ipc.send('frame-painted', '');
  //       })
  //     });
  //   `

  //   ipcMain.once("frame-painted", () => {
  //     callback()
  //   })
  //   this.window.evaluateScript(script, (result : any) => {})
  // }

  logSignal(str : string) {
    ipc.log(`RECEIVED: ${str}`)
  }
}

