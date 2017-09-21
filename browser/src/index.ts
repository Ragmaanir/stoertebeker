import {Server} from "./server"
const electron = require('electron')

class Application {
  app : typeof electron.app
  //browser : Browser | null
  server : Server | null

  constructor() {
    this.app = electron.app
    this.registerEvents()
  }

  registerEvents() {
    this.app.on('ready', () => {
      // this.browser = new Browser()
      this.server = new Server
      this.server.start()
    })

    // Quit when all windows are closed.
    this.app.on('window-all-closed', () => {
      this.app.quit()
      // // On macOS it is common for applications and their menu bar
      // // to stay active until the user quits explicitly with Cmd + Q
      // if (process.platform !== 'darwin') {
      //   this.app.quit()
      // }
    })

    // this.app.on('activate', () => {
    //   // On macOS it's common to re-create a window in the app when the
    //   // dock icon is clicked and there are no other windows open.
    //   if (this.browser === null) {
    //     this.browser = new Browser()
    //   }
    // })
  }
}

// let application = new Application()
// application.start()
new Application()
