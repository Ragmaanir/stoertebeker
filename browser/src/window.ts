import * as urlHelper from "url"

const electron = require('electron')
const BrowserWindow = electron.BrowserWindow
const NativeImage = electron.NativeImage
const Error = electron.Error

export class Window {
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
  }

  loadUrl(url : string) {
    this.window.loadURL(urlHelper.format({
      pathname: url,
      protocol: 'http:',
      slashes: true
    }))
  }

  close() {
    this.window.close()
  }

  setSize(w : number, h : number) {
    this.window.setSize(w, h)
  }

  evaluateScript(script : string, callback : (result : any) => void) {
    this.window.webContents.executeJavaScript(script, callback)
  }

  screenshot(file : string, callback : () => void) : void {
    this.window.capturePage((img : typeof NativeImage) => {
      require('fs').writeFile(file, img.toPng(), () => {
        callback()
      })
    })
  }

  savePage(file : string, callback : () => void) {
    this.window.webContents.savePage(file, 'HTMLComplete', (error : typeof Error) => {
      if (!error) {
        callback()
      } else {
        throw "Could not save HTML"
      }
    })
  }
}
