import { Controller } from "@hotwired/stimulus"

// Try to import FullCalendar modules, but also set up fallbacks to global objects
let Calendar, dayGridPlugin, timeGridPlugin, interactionPlugin;

try {
  // Attempt to load via ES modules
  Calendar = (window.FullCalendar && window.FullCalendar.Calendar) || 
             (typeof FullCalendar !== 'undefined' ? FullCalendar.Calendar : null);
  dayGridPlugin = (window.FullCalendar && window.FullCalendar.dayGridPlugin) || 
                 (typeof FullCalendarDayGrid !== 'undefined' ? FullCalendarDayGrid.default : null);
  timeGridPlugin = (window.FullCalendar && window.FullCalendar.timeGridPlugin) || 
                  (typeof FullCalendarTimeGrid !== 'undefined' ? FullCalendarTimeGrid.default : null);
  interactionPlugin = (window.FullCalendar && window.FullCalendar.interactionPlugin) || 
                     (typeof FullCalendarInteraction !== 'undefined' ? FullCalendarInteraction.default : null);
} catch (e) {
  console.warn('Error loading FullCalendar modules:', e);
  // Fallback to global objects if imports fail
  Calendar = window.FullCalendar ? window.FullCalendar.Calendar : null;
  dayGridPlugin = window.FullCalendar ? window.FullCalendar.dayGridPlugin : null;
  timeGridPlugin = window.FullCalendar ? window.FullCalendar.timeGridPlugin : null;
  interactionPlugin = window.FullCalendar ? window.FullCalendar.interactionPlugin : null;
}

export default class extends Controller {
  static targets = [
    "calendar", 
    "calendarTitle", 
    "modal", 
    "bulkEditModal", 
    "dateField", 
    "selectedDays"
  ]
  
  static values = { 
    taskId: { type: Number, default: 0 },
    organizationId: { type: Number, default: 0 }
  }
  
  connect() {
    // Extract task and organization IDs from data attributes
    const href = window.location.href
    const urlParts = href.split('/')
    
    // Find organization and task IDs from the URL
    for (let i = 0; i < urlParts.length; i++) {
      if (urlParts[i] === 'organizations' && i + 1 < urlParts.length) {
        this.organizationIdValue = urlParts[i + 1]
      }
      if (urlParts[i] === 'tasks' && i + 1 < urlParts.length) {
        this.taskIdValue = urlParts[i + 1]
      }
    }
    
    // Track shift key state
    this.shiftKeyPressed = false
    
    // Add keyboard event listeners
    this.handleKeyDown = this.handleKeyDown.bind(this)
    this.handleKeyUp = this.handleKeyUp.bind(this)
    document.addEventListener('keydown', this.handleKeyDown)
    document.addEventListener('keyup', this.handleKeyUp)
    
    this.initCalendar()
    this.selectedDates = new Set()
    this.dayClassMap = new Map()
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy()
      this.calendar = null
    }
    
    // Remove keyboard event listeners
    document.removeEventListener('keydown', this.handleKeyDown)
    document.removeEventListener('keyup', this.handleKeyUp)
  }

  initCalendar() {
    const calendarUrl = this.calendarTarget.dataset.calendarUrl
    
    // Use global FullCalendar if modules not available
    const CalendarClass = Calendar || (window.FullCalendar ? window.FullCalendar.Calendar : null);
    
    if (!CalendarClass) {
      console.error('FullCalendar library not found. Make sure it is properly loaded.');
      this.calendarTarget.innerHTML = '<div class="p-4 text-red-500">Error: FullCalendar library not found</div>';
      return;
    }
    
    const plugins = [];
    if (dayGridPlugin) plugins.push(dayGridPlugin);
    if (timeGridPlugin) plugins.push(timeGridPlugin);
    if (interactionPlugin) plugins.push(interactionPlugin);
    
    try {
      this.calendar = new CalendarClass(this.calendarTarget, {
        plugins: plugins,
        initialView: 'dayGridMonth',
        headerToolbar: false,
        selectable: true,
        editable: true,
        events: calendarUrl,
        dateClick: this.handleDateClick.bind(this),
        eventClick: this.handleEventClick.bind(this),
        datesSet: this.handleDatesSet.bind(this),
        select: this.handleSelect.bind(this),
        eventContent: this.renderEventContent.bind(this)
      });
      
      this.calendar.render();
    } catch (error) {
      console.error('Error initializing calendar:', error);
      this.calendarTarget.innerHTML = `<div class="p-4 text-red-500">Error initializing calendar: ${error.message}</div>`;
    }
  }

  handleDateClick(info) {
    // Use our tracked shift key state or the event's shiftKey
    if (this.shiftKeyPressed || (window.event && (window.event.shiftKey || window.event.ctrlKey || window.event.metaKey))) {
      this.toggleDateSelection(info.date)
    } else {
      // Open modal and prefill with the selected date
      if (this.dateFieldTarget) {
        this.dateFieldTarget.value = info.dateStr
        this.showModal()
      } else {
        console.error("Date field target not found")
      }
    }
  }

  handleEventClick(info) {
    // Navigate to the time entry detail page
    const eventId = info.event.id
    const orgId = this.organizationIdValue || this.calendarTarget.dataset.organizationId
    const taskId = this.taskIdValue || this.calendarTarget.dataset.taskId
    
    window.location.href = `/organizations/${orgId}/tasks/${taskId}/task_timetrackings/${eventId}`
  }

  handleDatesSet(info) {
    const title = info.view.title
    this.calendarTitleTarget.textContent = title
  }
  
  handleSelect(info) {
    // For multi-day selection with mouse drag
    const start = new Date(info.start)
    const end = new Date(info.end)
    
    // Decrement end by one day because FullCalendar uses exclusive end date
    end.setDate(end.getDate() - 1)
    
    // Select all days between start and end
    let date = new Date(start)
    while (date <= end) {
      this.selectDate(new Date(date))
      date.setDate(date.getDate() + 1)
    }
    
    this.updateSelectedDaysDisplay()
  }

  toggleDateSelection(date) {
    const dateStr = this.formatDate(date)
    
    if (this.selectedDates.has(dateStr)) {
      this.selectedDates.delete(dateStr)
      this.removeHighlightFromDate(dateStr)
    } else {
      this.selectedDates.add(dateStr)
      this.addHighlightToDate(dateStr)
    }
    
    this.updateSelectedDaysDisplay()
  }
  
  selectDate(date) {
    const dateStr = this.formatDate(date)
    this.selectedDates.add(dateStr)
    this.addHighlightToDate(dateStr)
  }
  
  addHighlightToDate(dateStr) {
    const dateEl = this.findDateElement(dateStr)
    if (dateEl) {
      dateEl.classList.add('selected-date')
      
      // Also add day-type class if it exists
      const dayClass = this.dayClassMap.get(dateStr)
      if (dayClass) {
        dateEl.classList.add(dayClass)
      }
    }
  }
  
  removeHighlightFromDate(dateStr) {
    const dateEl = this.findDateElement(dateStr)
    if (dateEl) {
      dateEl.classList.remove('selected-date')
      
      // Also remove day-type classes
      dateEl.classList.remove('work-day', 'vacation-day', 'sick-day')
    }
  }
  
  findDateElement(dateStr) {
    return this.calendarTarget.querySelector(`[data-date="${dateStr}"]`)
  }
  
  formatDate(date) {
    return date instanceof Date 
      ? date.toISOString().split('T')[0]
      : date
  }

  updateSelectedDaysDisplay() {
    if (this.selectedDates.size === 0) {
      this.selectedDaysTarget.innerHTML = '<p class="text-gray-500 text-sm italic">No days selected. Click on calendar days to select them.</p>'
      return
    }
    
    const dateList = Array.from(this.selectedDates).sort()
    const html = dateList.map(date => {
      const dayClass = this.dayClassMap.get(date) || ''
      const labelClass = this.getDayLabelClass(dayClass)
      
      return `
        <div class="flex justify-between items-center p-1 border-b">
          <span>${date}</span>
          <span class="badge ${labelClass}">${this.getDayTypeName(dayClass)}</span>
        </div>
      `
    }).join('')
    
    this.selectedDaysTarget.innerHTML = html
  }
  
  getDayTypeName(dayClass) {
    switch(dayClass) {
      case 'work-day': return 'Work'
      case 'vacation-day': return 'Vacation'
      case 'sick-day': return 'Sick'
      default: return 'Unset'
    }
  }
  
  getDayLabelClass(dayClass) {
    switch(dayClass) {
      case 'work-day': return 'bg-success text-white'
      case 'vacation-day': return 'bg-primary text-white'
      case 'sick-day': return 'bg-danger text-white'
      default: return 'bg-secondary text-white'
    }
  }
  
  renderEventContent(eventInfo) {
    return {
      html: `
        <div class="fc-event-time">${this.formatEventTime(eventInfo)}</div>
        <div class="fc-event-title">
          <strong>${eventInfo.event.extendedProps.duration} hrs</strong> - ${eventInfo.event.title}
        </div>
      `
    }
  }
  
  formatEventTime(eventInfo) {
    if (eventInfo.event.allDay) {
      return `${eventInfo.event.extendedProps.duration} hrs`
    }
    
    const startTime = eventInfo.event.start ? eventInfo.event.start.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''
    const endTime = eventInfo.event.end ? eventInfo.event.end.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''
    
    return startTime && endTime ? `${startTime} - ${endTime}` : startTime
  }
  
  showModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add('show')
      this.modalTarget.style.display = 'block'
    } else {
      console.error("Modal target not found")
    }
  }
  
  hideModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove('show')
      this.modalTarget.style.display = 'none'
    } else {
      console.error("Modal target not found")
    }
  }
  
  showBulkEditModal() {
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first (use shift+click to select days)")
      return
    }
    
    this.updateSelectedDaysDisplay()
    
    if (this.hasBulkEditModalTarget) {
      this.bulkEditModalTarget.classList.add('show')
      this.bulkEditModalTarget.style.display = 'block'
    } else {
      console.error("Bulk edit modal target not found")
    }
  }
  
  hideBulkEditModal() {
    if (this.hasBulkEditModalTarget) {
      this.bulkEditModalTarget.classList.remove('show')
      this.bulkEditModalTarget.style.display = 'none'
    } else {
      console.error("Bulk edit modal target not found")
    }
  }
  
  applyWorkDay() {
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first")
      return
    }
    this.applyDayClass('work-day')
  }
  
  applyVacationDay() {
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first")
      return
    }
    this.applyDayClass('vacation-day')
  }
  
  applySickDay() {
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first")
      return
    }
    this.applyDayClass('sick-day')
  }
  
  applyDayClass(className) {
    this.selectedDates.forEach(date => {
      this.dayClassMap.set(date, className)
    })
    
    this.updateSelectedDaysDisplay()
  }
  
  getSelectedDayType() {
    // Get the most common day type from selected days
    const typeCounts = {};
    
    this.selectedDates.forEach(date => {
      const type = this.dayClassMap.get(date) || 'unset';
      typeCounts[type] = (typeCounts[type] || 0) + 1;
    });
    
    let maxType = 'work-day';
    let maxCount = 0;
    
    for (const [type, count] of Object.entries(typeCounts)) {
      if (count > maxCount) {
        maxCount = count;
        maxType = type;
      }
    }
    
    return maxType;
  }
  
  applyStandardHours(event) {
    const hours = event.currentTarget.dataset.hours || 8
    
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first")
      return
    }
    
    window.showConfirmationModal(
      `Are you sure you want to add ${hours} hours to ${this.selectedDates.size} selected day(s)?`,
      () => this.processBulkUpdate('work', hours)
    )
  }
  
  clearHours() {
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first")
      return
    }
    
    window.showConfirmationModal(
      `Are you sure you want to clear time entries for ${this.selectedDates.size} selected day(s)?`,
      () => this.processBulkUpdate('delete', 0)
    )
  }
  
  processBulkUpdate(type, hours) {
    const orgId = this.organizationIdValue || this.element.dataset.organizationId
    const taskId = this.taskIdValue || this.element.dataset.taskId
    
    console.log(`Processing bulk update for task ${taskId} in org ${orgId}`)
    console.log(`Selected dates: ${Array.from(this.selectedDates).join(', ')}`)
    
    const url = `/organizations/${orgId}/tasks/${taskId}/task_timetrackings/bulk_update`
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    
    if (!csrfToken) {
      console.error("CSRF token not found")
      alert("Error: CSRF token not found. Please refresh the page and try again.")
      return
    }
    
    const entries = Array.from(this.selectedDates).map(date => ({
      date: date,
      type: type,
      hours: hours,
      delete: type === 'delete'
    }))
    
    if (entries.length === 0) {
      alert("No dates selected. Please select at least one date.")
      return
    }
    
    console.log(`Sending ${entries.length} entries to ${url}`)
    
    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ entries: entries })
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        alert(`Error: ${data.error}`)
        return
      }
      
      const successCount = data.success?.length || 0
      const errorCount = data.error?.length || 0
      
      let message = `Successfully processed ${successCount} entries.`
      if (errorCount > 0) {
        message += ` Failed to process ${errorCount} entries.`
      }
      
      alert(message)
      this.hideBulkEditModal()
      this.calendar.refetchEvents()
      
      // Clear selections after successful update
      this.selectedDates.clear()
      this.updateSelectedDaysDisplay()
      this.calendar.render()
    })
    .catch(error => {
      console.error('Error processing bulk update:', error)
      alert('An error occurred while processing your request. Please try again.')
    })
  }
  
  submitBulkEdit() {
    const dayType = this.getSelectedDayType()
    let hours = 0
    
    switch(dayType) {
      case 'work-day':
        hours = 8
        break
      case 'vacation-day':
        hours = 8
        break
      case 'sick-day':
        hours = 8
        break
      default:
        hours = 0
    }
    
    this.processBulkUpdate(dayType.replace('-day', ''), hours)
  }
  
  submitForm(event) {
    event.preventDefault()
    
    const form = event.target
    const formData = new FormData(form)
    
    // Log form data for debugging
    console.log("Submitting form...")
    for (let pair of formData.entries()) {
      console.log(pair[0] + ': ' + pair[1]);
    }
    
    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        'Accept': 'application/json'
      }
    })
    .then(response => {
      if (response.ok) {
        this.hideModal()
        this.calendar.refetchEvents()
        
        // Display success message
        const successMessage = document.createElement('div')
        successMessage.className = 'alert alert-success'
        successMessage.textContent = 'Time entry saved successfully!'
        successMessage.style.position = 'fixed'
        successMessage.style.top = '20px'
        successMessage.style.right = '20px'
        successMessage.style.zIndex = '9999'
        document.body.appendChild(successMessage)
        
        // Remove success message after 3 seconds
        setTimeout(() => {
          document.body.removeChild(successMessage)
        }, 3000)
      } else {
        return response.json().then(errors => {
          throw new Error(JSON.stringify(errors))
        })
      }
    })
    .catch(error => {
      console.error('Error saving time entry:', error)
      alert('Error saving time entry. Please check the console for details.')
    })
  }
  
  previous() {
    this.calendar.prev()
  }
  
  next() {
    this.calendar.next()
  }
  
  today() {
    this.calendar.today()
  }
  
  handleKeyDown(event) {
    if (event.key === 'Shift') {
      this.shiftKeyPressed = true
    }
  }
  
  handleKeyUp(event) {
    if (event.key === 'Shift') {
      this.shiftKeyPressed = false
    }
  }
}