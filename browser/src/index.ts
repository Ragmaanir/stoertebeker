import {Server} from "./server"
const electron = require('electron')

class Application {
  app : typeof electron.app
  server : Server | null

  constructor() {
    this.app = electron.app
    this.registerEvents()
  }

  registerEvents() {
    this.app.on('ready', () => {
      this.server = new Server
      this.server.start()
    })

    this.app.on('window-all-closed', () => {
      this.app.quit()
    })
  }
}

new Application()
