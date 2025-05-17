import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  
  connect() {
    // Optional: Initialize any state when the controller connects
  }
  
  debounce(event) {
    // Only proceed if the key is not Enter (which would submit the form naturally)
    if (event.key === "Enter") return
    
    // Clear any existing timeout
    clearTimeout(this.timeout)
    
    // Set a new timeout to submit the form after user stops typing
    this.timeout = setTimeout(() => {
      this.submit()
    }, 500) // 500ms debounce
  }
  
  submit() {
    // Submit the form to filter results
    this.element.requestSubmit()
  }
  
  clear() {
    // Clear the search input and submit the form
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    this.submit()
  }
}