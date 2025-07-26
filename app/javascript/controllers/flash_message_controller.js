import { Controller } from "@hotwired/stimulus"

// Conecta a elementos data-controller="flash-message"
export default class extends Controller {
  static values = { 
    delay: { type: Number, default: 5000 }
  }
  
  connect() {
    // Auto-dismiss después del tiempo especificado
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.delayValue)
  }
  
  disconnect() {
    // Limpiar el timeout si el elemento se desconecta antes
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
  
  dismiss() {
    // Animar la salida y luego remover el elemento
    this.element.classList.remove('show')
    
    setTimeout(() => {
      if (this.element && this.element.parentNode) {
        this.element.remove()
      }
    }, 150) // Tiempo para que termine la animación fade
  }
}
