import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 5000 } }
  static classes = ["hidden"]

  connect() {
    this.dismissTimer = setTimeout(() => this.dismiss(), this.durationValue)
  }

  disconnect() {
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
    }
  }

  dismiss() {
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
    }
    this.element.classList.add(this.hiddenClass)
    setTimeout(() => this.element.remove(), 300)
  }
}
