// import * as path from "path"
import * as urlHelper from "url"
// import * as Electron from "electron"

const electron = require('electron')
const BrowserWindow = electron.BrowserWindow
const NativeImage = electron.NativeImage
// import {BrowserWindow, NativeImage} from "electron"

// FIXME
// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.


//let win : typeof BrowserWindow

export class Window {
  // window? : typeof BrowserWindow
  window : typeof BrowserWindow

  constructor() {
    this.window = new BrowserWindow({
      width: 800,
      height: 600,
      skipTaskbar: true,
      frame: false,
      show: false
    })

    this.registerEvents()
  }

  registerEvents() {
    this.window.once('closed', () => {
      // Dereference the window object, usually you would store windows
      // in an array if your app supports multi windows, this is the time
      // when you should delete the corresponding element.
      this.window = null
    })

    // this.window.on("ready-to-show", (event : Event) => {
    //   this.ready = true

    //   // if(client_socket) {
    //   //   ipc.server.emit(client_socket, 'ready')
    //   // }

    //   // FIXME
    //   //this.server.emit('ready')
    // })
  }

  loadUrl(url : string) {
    this.window.loadURL(urlHelper.format({
      pathname: url,
      protocol: 'http:',
      slashes: true
    }))
    // this.window.loadURL(url.format({
    //   pathname: path.join(__dirname, '../src/index.html'),
    //   protocol: 'file:',
    //   slashes: true
    // }))
  }

  close() {
    this.window.close()
  }

  screenshot(name : string, callback : () => void) : void {
    this.window.capturePage((img : typeof NativeImage) => {
      require('fs').writeFile(name, img.toPng(), () => {
        callback()
      })
    })
  }
}

// createWindow () {


//   // win.webContents.openDevTools()

//   // child.once('ready-to-show', () => {
//   //   child.show()
//   // })

//   // win.on('resize', (event : Event) => {
//   //   console.log("resize")
//   // })

//   // win.once('close', () => {
//   //   console.log("close")
//   // })

//   // Emitted when the window is closed.
//   win.once('closed', () => {
//     // Dereference the window object, usually you would store windows
//     // in an array if your app supports multi windows, this is the time
//     // when you should delete the corresponding element.
//     win = null
//   })

//   let ready = false

//   win.on("ready-to-show", (event : Event) => {
//     console.log("ready-to-show")

//     ready = true

//     if(client_socket) {
//       ipc.server.emit(client_socket, 'ready')
//     }
//   })

//   let client_socket : Socket | null = null

//   let screenshot = (name : string, callback : () => void) => {
//     win.capturePage((img : typeof NativeImage) => {
//       require('fs').writeFile(name, img.toPng(), () => {
//         console.log(img.toPng().length)
//         callback()
//       })
//     })
//   }

//   // let contents = win.webContents

//   // contents.once("dom-ready", (event : Event) => {
//   //   console.log("dom-ready")
//   // })

//   // contents.on("paint", (event : Event) => {
//   //   console.log("PAINT")
//   // })

//   // contents.once("did-finish-load", (event : Event) => {
//   //   console.log("did-finish-load")
//   //   // contents.executeJavaScript("1+1", () => {
//   //   // })
//   // })

//   // and load the index.html of the app.
//   win.loadURL(url.format({
//     pathname: path.join(__dirname, '../src/index.html'),
//     protocol: 'file:',
//     slashes: true
//   }))
// }
