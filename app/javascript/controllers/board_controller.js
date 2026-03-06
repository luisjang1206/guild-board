import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["connectionStatus"]

  connect() {
    this.wasDisconnected = false
    this.streamSourceEl = null
    this.streamSourceParent = null

    this.connectionObserver = new MutationObserver(this.handleConnectionMutations.bind(this))
    this.startObserving()

    this.handleDragStart = this.pauseStream.bind(this)
    this.handleDragEnd = this.resumeStream.bind(this)
    document.addEventListener("board:drag-start", this.handleDragStart)
    document.addEventListener("board:drag-end", this.handleDragEnd)
  }

  disconnect() {
    this.connectionObserver?.disconnect()
    document.removeEventListener("board:drag-start", this.handleDragStart)
    document.removeEventListener("board:drag-end", this.handleDragEnd)
  }

  startObserving() {
    const streamSources = document.querySelectorAll("turbo-cable-stream-source")
    streamSources.forEach(source => {
      this.connectionObserver.observe(source, { attributes: true, attributeFilter: ["connected"] })
      this.updateStatus(source.hasAttribute("connected"))
    })
  }

  handleConnectionMutations(mutations) {
    for (const mutation of mutations) {
      if (mutation.attributeName === "connected") {
        const isConnected = mutation.target.hasAttribute("connected")
        this.updateStatus(isConnected)

        if (isConnected && this.wasDisconnected) {
          this.syncBoard()
        }

        if (!isConnected) {
          this.wasDisconnected = true
        }
      }
    }
  }

  updateStatus(isConnected) {
    if (!this.hasConnectionStatusTarget) return

    const dot = this.connectionStatusTarget.querySelector("[data-dot]")
    const text = this.connectionStatusTarget.querySelector("[data-text]")

    if (isConnected) {
      dot.classList.remove("bg-red-500")
      dot.classList.add("bg-green-500")
      text.textContent = this.connectionStatusTarget.dataset.connectedText || "Connected"
      this.connectionStatusTarget.classList.add("opacity-0")
    } else {
      dot.classList.remove("bg-green-500")
      dot.classList.add("bg-red-500")
      text.textContent = this.connectionStatusTarget.dataset.disconnectedText || "Disconnected"
      this.connectionStatusTarget.classList.remove("opacity-0")
    }
  }

  pauseStream() {
    const source = document.querySelector("turbo-cable-stream-source")
    if (source) {
      this.streamSourceParent = source.parentElement
      this.streamSourceEl = source
      source.remove()
    }
  }

  resumeStream() {
    if (this.streamSourceEl && this.streamSourceParent) {
      this.streamSourceParent.prepend(this.streamSourceEl)
      this.streamSourceEl = null
      this.streamSourceParent = null
    }
    // Sync board after drag to get latest state
    setTimeout(() => this.syncBoard(), 200)
  }

  syncBoard() {
    const boardFrame = document.querySelector("turbo-frame#board")
    if (boardFrame) {
      boardFrame.reload()
    }
  }
}
