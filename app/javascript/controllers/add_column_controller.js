import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "form", "nameInput"]

  show() {
    this.triggerTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    if (this.hasNameInputTarget) {
      this.nameInputTarget.focus()
    }
  }

  hide() {
    this.triggerTarget.classList.remove("hidden")
    this.formTarget.classList.add("hidden")
    if (this.hasNameInputTarget) {
      this.nameInputTarget.value = ""
    }
  }

  keydown(event) {
    if (event.key === "Escape") this.hide()
  }

  submitEnd(event) {
    if (event.detail.success) this.hide()
  }
}
