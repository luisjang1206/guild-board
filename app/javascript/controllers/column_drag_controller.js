import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { projectId: Number }

  connect() {
    this.sortable = new Sortable(this.element, {
      animation: 150,
      draggable: "[data-column-draggable]",
      ghostClass: "opacity-30",
      direction: "horizontal",
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  onEnd(evt) {
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
    })
  }
}
