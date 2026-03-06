import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["priority", "label", "creatorType"]
  static values = { frameId: String }

  filter() {
    const params = new URLSearchParams()
    const priority = this.priorityTarget.value
    const label = this.labelTarget.value
    const creatorType = this.creatorTypeTarget.value

    if (priority) params.set("priority", priority)
    if (label) params.set("label_id", label)
    if (creatorType) params.set("creator_type", creatorType)

    const frame = document.getElementById(this.frameIdValue)
    if (frame) {
      const baseUrl = window.location.pathname
      const query = params.toString()
      frame.src = query ? `${baseUrl}?${query}` : baseUrl

      // Update URL without reload
      const newUrl = query ? `${window.location.pathname}?${query}` : window.location.pathname
      history.replaceState({}, "", newUrl)
    }
  }

  clearAll() {
    this.priorityTarget.value = ""
    this.labelTarget.value = ""
    this.creatorTypeTarget.value = ""
    this.filter()
  }
}
