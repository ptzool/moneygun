import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "startTime", "endTime", "duration" ]

  connect() {
    console.log("Time entry form controller connected")

    // Check if we have start and end times
    const startField = this.element.querySelector('input[name*="[start]"]')
    const endField = this.element.querySelector('input[name*="[end]"]')

    if (startField?.value && endField?.value) {
      this.calculateDuration()
    }

    this.addEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
  }

  addEventListeners() {
    const startField = this.element.querySelector('input[name*="[start]"]')
    const endField = this.element.querySelector('input[name*="[end]"]')
    const durationField = this.element.querySelector('input[name*="[duration_in_hours]"]')

    console.log("Fields found:", !!startField, !!endField, !!durationField)

    // Use input event for immediate feedback as user types
    if (startField) {
      startField.addEventListener('change', this.updateDuration.bind(this))
      startField.addEventListener('input', this.updateDuration.bind(this))
    }

    if (endField) {
      endField.addEventListener('change', this.updateDuration.bind(this))
      endField.addEventListener('input', this.updateDuration.bind(this))
    }

    if (durationField) {
      durationField.addEventListener('change', this.updateTimes.bind(this))
      durationField.addEventListener('input', this.updateTimes.bind(this))
    }
  }

  removeEventListeners() {
    const startField = this.element.querySelector('input[name*="[start]"]')
    const endField = this.element.querySelector('input[name*="[end]"]')
    const durationField = this.element.querySelector('input[name*="[duration_in_hours]"]')
    
    // Remove all event listeners
    if (startField) {
      startField.removeEventListener('change', this.updateDuration.bind(this))
      startField.removeEventListener('input', this.updateDuration.bind(this))
    }
    
    if (endField) {
      endField.removeEventListener('change', this.updateDuration.bind(this))
      endField.removeEventListener('input', this.updateDuration.bind(this))
    }
    
    if (durationField) {
      durationField.removeEventListener('change', this.updateTimes.bind(this))
      durationField.removeEventListener('input', this.updateTimes.bind(this))
    }
  }

  updateDuration() {
    this.calculateDuration()
  }

  calculateDuration() {
    const startField = this.element.querySelector('input[name*="[start]"]')
    const endField = this.element.querySelector('input[name*="[end]"]')
    const durationField = this.element.querySelector('input[name*="[duration_in_hours]"]')
    
    console.log("Calculating duration with fields:", !!startField, !!endField, !!durationField)
    console.log("Field values:", startField?.value, endField?.value)
    
    if (!startField || !endField || !durationField) {
      console.log("Missing required fields for duration calculation")
      return
    }
    
    // If either start or end time is missing, don't recalculate
    if (!startField.value || !endField.value) {
      console.log("Start or end time missing - not recalculating")
      return
    }
    
    // Parse start and end times
    const startParts = startField.value.split(':')
    const endParts = endField.value.split(':')
    
    if (startParts.length < 2 || endParts.length < 2) {
      console.log("Invalid time format")
      return
    }
    
    const startHours = parseInt(startParts[0])
    const startMinutes = parseInt(startParts[1])
    const endHours = parseInt(endParts[0])
    const endMinutes = parseInt(endParts[1])
    
    // Validate parsed values
    if (isNaN(startHours) || isNaN(startMinutes) || isNaN(endHours) || isNaN(endMinutes)) {
      console.log("Invalid time values")
      return
    }
    
    // Calculate total minutes
    let durationMinutes = (endHours * 60 + endMinutes) - (startHours * 60 + startMinutes)
    
    // Handle overnight shifts
    if (durationMinutes < 0) {
      durationMinutes += 24 * 60
    }
    
    // Convert to hours
    const durationHours = durationMinutes / 60
    
    // Update the duration field with 2 decimal places
    console.log(`Duration calculated: ${durationHours.toFixed(2)} hours`)
    durationField.value = durationHours.toFixed(2)
  }

  updateTimes(event) {
    console.log("Updating times")
    const durationField = this.element.querySelector('input[name*="[duration_in_hours]"]')
    const startField = this.element.querySelector('input[name*="[start]"]')
    const endField = this.element.querySelector('input[name*="[end]"]')
    
    if (!durationField || !durationField.value) {
      console.log("Duration field missing or empty")
      return
    }
    
    // Parse duration as a floating point number
    const durationHours = parseFloat(durationField.value)
    if (isNaN(durationHours) || durationHours <= 0) {
      console.log("Invalid duration value:", durationField.value)
      return
    }
    
    const durationMinutes = Math.round(durationHours * 60)
    console.log(`Duration: ${durationHours} hours (${durationMinutes} minutes)`)
    
    // If we have a start time but no end time, calculate the end time based on duration
    if (startField && startField.value && !endField.value) {
      const startParts = startField.value.split(':')
      if (startParts.length < 2) {
        console.log("Invalid start time format")
        return
      }
      
      const startHours = parseInt(startParts[0])
      const startMinutes = parseInt(startParts[1])
      
      if (isNaN(startHours) || isNaN(startMinutes)) {
        console.log("Invalid start time values")
        return
      }
      
      let totalMinutes = startHours * 60 + startMinutes + durationMinutes
      
      // Handle overnight shifts
      while (totalMinutes >= 24 * 60) {
        totalMinutes -= 24 * 60
      }
      
      const endHours = Math.floor(totalMinutes / 60)
      const endMinutes = Math.round(totalMinutes % 60)
      
      // Format end time with leading zeros
      const formattedEndTime = `${endHours.toString().padStart(2, '0')}:${endMinutes.toString().padStart(2, '0')}`
      console.log(`Calculated end time: ${formattedEndTime}`)
      endField.value = formattedEndTime
    }
    
    // If we have an end time but no start time, calculate the start time based on duration
    else if (endField && endField.value && !startField.value) {
      const endParts = endField.value.split(':')
      if (endParts.length < 2) {
        console.log("Invalid end time format")
        return
      }
      
      const endHours = parseInt(endParts[0])
      const endMinutes = parseInt(endParts[1])
      
      if (isNaN(endHours) || isNaN(endMinutes)) {
        console.log("Invalid end time values")
        return
      }
      
      let totalMinutes = endHours * 60 + endMinutes - durationMinutes
      
      // Handle overnight shifts
      while (totalMinutes < 0) {
        totalMinutes += 24 * 60
      }
      
      const startHours = Math.floor(totalMinutes / 60)
      const startMinutes = Math.round(totalMinutes % 60)
      
      // Format start time with leading zeros
      const formattedStartTime = `${startHours.toString().padStart(2, '0')}:${startMinutes.toString().padStart(2, '0')}`
      console.log(`Calculated start time: ${formattedStartTime}`)
      startField.value = formattedStartTime
    }
    // If both start and end times are present, recalculate the duration
    else if (startField && startField.value && endField && endField.value) {
      this.calculateDuration()
    }
  }
}
