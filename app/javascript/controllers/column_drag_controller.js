import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { projectId: Number }

  connect() {
    this.isDragging = false
    this.createSortable()
    this.observeChildren()
  }

  disconnect() {
    this.sortable?.destroy()
    this.childObserver?.disconnect()
  }

  createSortable() {
    this.sortable?.destroy()
    this.sortable = new Sortable(this.element, {
      animation: 150,
      draggable: "[data-column-draggable]",
      ghostClass: "opacity-30",
      direction: "horizontal",
      onStart: this.onStart.bind(this),
      onEnd: this.onEnd.bind(this)
    })
  }

  observeChildren() {
    this.childObserver = new MutationObserver(() => {
      if (!this.isDragging) {
        this.createSortable()
      }
    })
    this.childObserver.observe(this.element, { childList: true })
  }

  onStart() {
    this.isDragging = true
    document.dispatchEvent(new CustomEvent("board:drag-start"))
  }

  onEnd(evt) {
    this.isDragging = false

    const columnId = evt.item.dataset.columnId
    if (!columnId) return
    const newPosition = evt.newIndex
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(`/projects/${this.projectIdValue}/board_columns/${columnId}/move`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({ position: newPosition })
    }).then(response => {
      if (!response.ok) {
        evt.from.insertBefore(evt.item, evt.from.children[evt.oldIndex] || null)
      }
      document.dispatchEvent(new CustomEvent("board:drag-end"))
    })
  }
}
