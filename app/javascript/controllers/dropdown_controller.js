import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static classes = ["hidden"]

  connect() {
    this.boundClickOutside = (event) => {
      if (!this.element.contains(event.target)) {
        this.hide()
      }
    }
    document.addEventListener("click", this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggle() {
    this.menuTarget.classList.toggle(this.hiddenClass)
  }

  hide() {
    this.menuTarget.classList.add(this.hiddenClass)
  }
}
