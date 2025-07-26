import { Controller } from "@hotwired/stimulus"

// Conecta a elementos data-controller="price-update"
export default class extends Controller {
  connect() {
    // Añadir una pequeña animación cuando se actualiza el precio
    this.element.classList.add("price-updated")
    
    // Remover la clase después de la animación
    setTimeout(() => {
      this.element.classList.remove("price-updated")
    }, 2000)
  }
}
