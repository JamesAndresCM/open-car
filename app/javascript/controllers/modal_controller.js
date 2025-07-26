import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.modal = new bootstrap.Modal(this.element)
    this.modal.show()
  }

  disconnect() {
    if (this.modal) {
      this.modal.hide()
    }
  }

  close() {
    this.modal.hide()
  }
}