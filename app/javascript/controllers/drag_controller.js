import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { projectId: Number }

  connect() {
    this.sortable = new Sortable(this.element, {
      group: "board",
      animation: 150,
      draggable: "[data-drag-item]",
      ghostClass: "opacity-30",
      dragClass: "rotate-2",
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  onEnd(evt) {
    const taskId = evt.item.dataset.taskId
    const newColumnEl = evt.to.closest("[data-column-id]")
    if (!newColumnEl) return

    const newColumnId = newColumnEl.dataset.columnId
    const newPosition = evt.newIndex
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(`/projects/${this.projectIdValue}/tasks/${taskId}/move`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({ board_column_id: newColumnId, position: newPosition })
    }).then(response => {
      if (!response.ok) {
        // Rollback: move item back to original position
        evt.from.insertBefore(evt.item, evt.from.children[evt.oldIndex] || null)
      }
    })
  }
}
