import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["duration"]

  connect() {
    // Initialize when connected
    this.initialized = true
  }

  resetForm(event) {
    // Only reset if the form submission was successful
    if (event.detail.success) {
      this.element.reset()
      
      // Reset fields to default values
      const dateInput = this.element.querySelector('input[name*="[date]"]')
      if (dateInput) {
        dateInput.value = new Date().toISOString().split('T')[0]
      }
      
      // Focus on the duration field to prepare for next entry
      const durationInput = this.element.querySelector('input[name*="[duration_in_hours]"]')
      if (durationInput) {
        durationInput.value = "1.0"
      }
      
      // Show success message
      this.showToast("Time entry added successfully")
    }
  }

  updateDuration(event) {
    const startInput = this.element.querySelector('input[name*="[start]"]')
    const endInput = this.element.querySelector('input[name*="[end]"]')
    const durationTarget = this.hasDurationTarget ? this.durationTarget : 
                          this.element.querySelector('input[name*="[duration_in_hours]"]')
    
    if (startInput && endInput && durationTarget && startInput.value && endInput.value) {
      const start = this.parseTimeInput(startInput.value)
      const end = this.parseTimeInput(endInput.value)
      
      if (start && end) {
        // Calculate duration in hours
        let durationInHours = (end - start) / (1000 * 60 * 60)
        
        // If end time is earlier than start time, assume it's the next day
        if (durationInHours < 0) {
          durationInHours += 24
        }
        
        // Round to nearest quarter hour
        durationInHours = Math.round(durationInHours * 4) / 4
        
        // Only update if the duration is valid
        if (durationInHours > 0) {
          durationTarget.value = durationInHours.toFixed(2)
        }
      }
    }
  }

  parseTimeInput(timeStr) {
    // Time inputs are in the format HH:MM
    const [hours, minutes] = timeStr.split(':').map(Number)
    
    if (!isNaN(hours) && !isNaN(minutes)) {
      const date = new Date()
      date.setHours(hours, minutes, 0, 0)
      return date
    }
    
    return null
  }
  
  showToast(message) {
    // Create toast element if a toast system exists
    const event = new CustomEvent('toast:show', { 
      bubbles: true, 
      detail: { message, type: 'success' } 
    })
    this.element.dispatchEvent(event)
  }
}