import { Controller } from "@hotwired/stimulus"

// Conecta a elementos data-controller="results-counter"
export default class extends Controller {
  static values = { count: Number }
  
  connect() {
    console.log("ResultsCounter controller connected with count:", this.countValue)
    this.updateCounter()
  }
  
  countValueChanged() {
    console.log("Count value changed to:", this.countValue)
    this.updateCounter()
  }
  
  updateCounter() {
    const resultsCountElement = document.getElementById('results_count')
    if (resultsCountElement) {
      const count = this.countValue
      const plural = count === 1 ? '' : 's'
      resultsCountElement.innerHTML = `${count} resultado${plural}`
      console.log('🔄 Updated results count to:', count)
    } else {
      console.warn('❌ Results count element not found')
    }
  }
}
