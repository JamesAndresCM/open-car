import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "cancelButton"]

  connect() {
    this.originalSrc = this.previewTarget.src
    this.hasOriginal = this.originalSrc && this.originalSrc !== "#" && !this.previewTarget.classList.contains("d-none")
  }

  previewImage() {
    const file = this.inputTarget.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("d-none")
        this.cancelButtonTarget.classList.remove("d-none")
      }
      reader.readAsDataURL(file)
    }
  }

  cancelPreview() {
    this.inputTarget.value = ""
    if (this.hasOriginal) {
      this.previewTarget.src = this.originalSrc
    } else {
      this.previewTarget.src = "#"
      this.previewTarget.classList.add("d-none")
    }
    this.cancelButtonTarget.classList.add("d-none")
  }
}
