import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    // 프레임에 컨텐츠가 로드되면 자동 오픈
    this.dialogTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    this.boundKeydown = (event) => {
      if (event.key === "Escape") this.close()
    }
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
    document.body.style.overflow = ""
  }

  close() {
    this.dialogTarget.classList.add("hidden")
    document.body.style.overflow = ""
    // Turbo Frame의 src를 지워서 내용 제거
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.innerHTML = ""
      frame.removeAttribute("src")
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}
