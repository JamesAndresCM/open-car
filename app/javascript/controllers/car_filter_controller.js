import { Controller } from "@hotwired/stimulus"

// Conecta a elementos data-controller="car-filter"
export default class extends Controller {
  static targets = ["form", "searchInput", "submitButton"]
  
  connect() {
    // Debounce timer para búsqueda en tiempo real
    this.searchTimeout = null
    this.debounceDelay = 500 // 500ms de delay
    
    console.log("CarFilter controller connected")
  }
  
  disconnect() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
  }
  
  disconnect() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
  }
  
  // Filtrar inmediatamente cuando cambian selects
  filter(event) {
    console.log("Filter triggered by:", event.target.tagName, event.target.type)
    
    // Para selects, filtrar inmediatamente
    if (event.target.tagName === "SELECT") {
      this.submitForm()
    }
  }
  
  // Filtrar con delay para campos de texto (evitar muchas requests)
  delayedFilter(event) {
    console.log("DelayedFilter triggered by:", event.target.tagName, event.target.type)
    
    // Solo aplicar delay a campos de texto y number
    if (event.target.type === "text" || event.target.type === "number") {
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout)
      }
      
      this.searchTimeout = setTimeout(() => {
        this.submitForm()
      }, this.debounceDelay)
    }
  }
  
  // Limpiar todos los filtros
  clearFilters(event) {
    event.preventDefault()
    console.log("Clearing filters")
    
    // Limpiar todos los campos del formulario
    const form = this.formTarget
    const inputs = form.querySelectorAll('input, select')
    
    inputs.forEach(input => {
      if (input.type === 'text' || input.type === 'number') {
        input.value = ''
      } else if (input.tagName === 'SELECT') {
        input.selectedIndex = 0
      }
    })
    
    // Enviar formulario con filtros limpiados
    this.submitForm()
  }
  
  // Función privada para enviar el formulario
  submitForm() {
    console.log("Submitting form...")
    
    // Mostrar loading en el botón si existe
    if (this.hasSubmitButtonTarget) {
      const originalText = this.submitButtonTarget.textContent
      this.submitButtonTarget.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Filtrando...'
      this.submitButtonTarget.disabled = true
      
      // Restaurar botón después de un tiempo
      setTimeout(() => {
        this.submitButtonTarget.textContent = originalText
        this.submitButtonTarget.disabled = false
      }, 2000)
    }
    
    // Usar el método nativo de Rails para enviar el formulario
    this.formTarget.requestSubmit()
  }
}
