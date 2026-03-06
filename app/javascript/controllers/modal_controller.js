import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    this.boundKeydown = (event) => {
      if (event.key === "Escape") this.close()
    }
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
    document.body.style.overflow = ""
  }

  open() {
    this.dialogTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.dialogTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}
