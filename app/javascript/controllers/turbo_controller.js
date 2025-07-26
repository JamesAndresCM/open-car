import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this.click.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("click", this.click.bind(this))
  }

  click(event) {
    event.preventDefault()
    const url = this.element.getAttribute("href")
    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
} 