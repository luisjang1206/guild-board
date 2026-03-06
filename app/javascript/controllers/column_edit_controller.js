import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values = { url: String }

  edit() {
    this.displayTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.inputTarget.querySelector("input").focus()
  }

  save() {
    const input = this.inputTarget.querySelector("input")
    const name = input.value.trim()
    if (!name) return this.cancel()

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    fetch(this.urlValue, {
      method: "PATCH",
      headers: { "X-CSRF-Token": csrfToken, "Content-Type": "application/json" },
      body: JSON.stringify({ board_column: { name } })
    }).then(response => {
      if (response.ok) {
        this.displayTarget.textContent = name
        this.cancel()
      }
    })
  }

  cancel() {
    this.displayTarget.classList.remove("hidden")
    this.inputTarget.classList.add("hidden")
  }

  keydown(event) {
    if (event.key === "Enter") this.save()
    if (event.key === "Escape") this.cancel()
  }
}
