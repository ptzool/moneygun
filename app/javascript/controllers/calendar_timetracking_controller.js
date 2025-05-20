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
    console.log("Calendar timetracking controller connected");
    // Extract task and organization IDs from data attributes
    const href = window.location.href;
    const urlParts = href.split('/');
    
    // Find organization and task IDs from the URL
    for (let i = 0; i < urlParts.length; i++) {
      if (urlParts[i] === 'organizations' && i + 1 < urlParts.length) {
        this.organizationIdValue = urlParts[i + 1];
      }
      if (urlParts[i] === 'tasks' && i + 1 < urlParts.length) {
        this.taskIdValue = urlParts[i + 1];
      }
    }
    
    // Track shift key state
    this.shiftKeyPressed = false;
    
    // Bind all methods that need 'this' context
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleKeyUp = this.handleKeyUp.bind(this);
    this.handleDateClick = this.handleDateClick.bind(this);
    this.handleEventClick = this.handleEventClick.bind(this);
    this.handleDatesSet = this.handleDatesSet.bind(this);
    this.handleSelect = this.handleSelect.bind(this);
    this.renderEventContent = this.renderEventContent.bind(this);
    this.showModal = this.showModal.bind(this);
    this.hideModal = this.hideModal.bind(this);
    this.handleManualDateClick = this.handleManualDateClick.bind(this);
    
    // Add keyboard event listeners
    document.addEventListener('keydown', this.handleKeyDown);
    document.addEventListener('keyup', this.handleKeyUp);
    
    // Set up data structures
    this.selectedDates = new Set();
    this.dayClassMap = new Map();
    
    // Initialize calendar with a delay to ensure DOM is fully ready
    setTimeout(() => {
      try {
        if (this.hasCalendarTarget) {
          console.log("Initializing calendar");
          this.initCalendar();
        } else {
          console.error("Calendar target not found on connect");
        }
        
        // Add global click handler for calendar day cells as a fallback
        const calendarContainer = document.getElementById('calendar-container');
        if (calendarContainer) {
          calendarContainer.addEventListener('click', (e) => {
            // Only process if we're not holding shift/ctrl/meta (for selections)
            if (!e.shiftKey && !e.ctrlKey && !e.metaKey) {
              const dayCell = e.target.closest('.fc-daygrid-day');
              if (dayCell) {
                const dateStr = dayCell.getAttribute('data-date');
                if (dateStr) {
                  console.log("Global click handler detected day click:", dateStr);
                  // Prevent default to avoid confusion with other handlers
                  e.preventDefault();
                  // Small delay to ensure we're not conflicting with FullCalendar's handler
                  setTimeout(() => {
                    this.handleManualDateClick(dateStr);
                  }, 10);
                }
              }
            }
          });
          console.log("Global click handler registered");
        }
      } catch (error) {
        console.error("Error in connect method:", error);
      }
    }, 300);
  }
  
  // Manual date click handler as a more reliable fallback
  handleManualDateClick(dateStr) {
    console.log("Manual date click on:", dateStr);
    try {
      // Direct DOM manipulation approach
      const dateField = document.querySelector('input[name="task_timetracking[date]"]');
      if (dateField) {
        // Set the date value
        dateField.value = dateStr;
        console.log("Date field value set to:", dateField.value);
        
        // Show the modal directly
        const modal = document.getElementById('timeEntryModal');
        if (modal) {
          modal.classList.add('show');
          modal.style.display = 'block';
          
          // Setup default time values - 9 AM to 5 PM for convenience
          const startField = modal.querySelector('input[name="task_timetracking[start]"]');
          const endField = modal.querySelector('input[name="task_timetracking[end]"]');
          const durationField = modal.querySelector('input[name="task_timetracking[duration_in_hours]"]');
          
          if (startField && !startField.value) startField.value = "09:00";
          if (endField && !endField.value) endField.value = "17:00";
          if (durationField && !durationField.value) durationField.value = "8.0";
          
          console.log("Modal displayed successfully");
        } else {
          console.error("Time entry modal not found");
          alert("Could not open the time entry form. Please try the New Time Entry button instead.");
        }
      } else {
        console.error("Date field not found in the form");
        // Redirect to the new time entry page as a last resort
        window.location.href = document.querySelector('a[href*="new_organization_task_task_timetracking"]')?.href;
      }
    } catch (error) {
      console.error("Error in manual date click handler:", error);
      alert("Something went wrong. Please try using the New Time Entry button instead.");
    }
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
    console.log("Date clicked:", info.dateStr);
    // Use our tracked shift key state or the event's shiftKey
    if (this.shiftKeyPressed || (window.event && (window.event.shiftKey || window.event.ctrlKey || window.event.metaKey))) {
      this.toggleDateSelection(info.date);
      return;
    }
    
    // Open the create time entry form with the selected date
    try {
      // First try to use direct DOM manipulation as the most reliable method
      const dateField = document.querySelector('input[name="task_timetracking[date]"]');
      if (dateField) {
        dateField.value = info.dateStr;
        
        // Open the modal directly
        const modal = document.getElementById('timeEntryModal');
        if (modal) {
          modal.classList.add('show');
          modal.style.display = 'block';
          return;
        }
      }
      
      // Fall back to our manual handler if the direct approach fails
      this.handleManualDateClick(info.dateStr);
    } catch (error) {
      console.error("Error in handleDateClick:", error);
      // Final fallback - try the manual method
      this.handleManualDateClick(info.dateStr);
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
    const dateStr = this.formatDate(date);
    console.log("toggleDateSelection called for date:", dateStr);
    
    if (this.selectedDates.has(dateStr)) {
      console.log("Date was already selected, removing:", dateStr);
      this.selectedDates.delete(dateStr);
      this.dayClassMap.delete(dateStr);
      this.removeHighlightFromDate(dateStr);
    } else {
      console.log("Date was not selected, adding:", dateStr);
      this.selectedDates.add(dateStr);
      this.addHighlightToDate(dateStr);
    }
    
    console.log("Selected dates count after toggle:", this.selectedDates.size);
    
    if (this.hasSelectedDaysTarget) {
      this.updateSelectedDaysDisplay();
    }
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
    console.log("Showing modal");
    try {
      // Direct DOM selection as most reliable method
      const modal = document.getElementById('timeEntryModal');
      if (modal) {
        console.log("Found modal by ID");
        modal.classList.add('show');
        modal.style.display = 'block';
        
        // Ensure any default values are set
        const dateField = modal.querySelector('input[name="task_timetracking[date]"]');
        const startField = modal.querySelector('input[name="task_timetracking[start]"]');
        const endField = modal.querySelector('input[name="task_timetracking[end]"]');
        const durationField = modal.querySelector('input[name="task_timetracking[duration_in_hours]"]');
        
        // Set today's date if no date is selected
        if (dateField && !dateField.value) {
          const today = new Date();
          const year = today.getFullYear();
          const month = String(today.getMonth() + 1).padStart(2, '0');
          const day = String(today.getDate()).padStart(2, '0');
          dateField.value = `${year}-${month}-${day}`;
        }
        
        // Set default times if not set
        if (startField && !startField.value) startField.value = "09:00";
        if (endField && !endField.value) endField.value = "17:00";
        if (durationField && !durationField.value) durationField.value = "8.0";
        
        console.log("Modal and defaults displayed successfully");
        return;
      }
      
      // Fallback to Stimulus target
      if (this.hasModalTarget) {
        this.modalTarget.classList.add('show');
        this.modalTarget.style.display = 'block';
      } else {
        console.error("Modal not found by any method");
        // Last resort - redirect to the new page
        window.location.href = document.querySelector('a[href*="new_organization_task_task_timetracking"]')?.href;
      }
    } catch (error) {
      console.error("Error showing modal:", error);
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
    console.log("showBulkEditModal called");
    console.log("Selected dates count:", this.selectedDates.size);
    console.log("Selected dates:", Array.from(this.selectedDates));
    
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first (use shift+click to select days)");
      return;
    }
    
    this.updateSelectedDaysDisplay();
    console.log("Updated selected days display");
    
    if (this.hasBulkEditModalTarget) {
      console.log("Showing bulk edit modal");
      this.bulkEditModalTarget.classList.add('show');
      this.bulkEditModalTarget.style.display = 'block';
    } else {
      console.error("Bulk edit modal target not found");
      // Try direct DOM access as fallback
      const modal = document.getElementById('bulkEditModal');
      if (modal) {
        console.log("Found bulk edit modal by ID, showing it");
        modal.classList.add('show');
        modal.style.display = 'block';
      } else {
        console.error("Bulk edit modal not found by any method");
        alert("Error: Could not display the bulk edit modal. Please try refreshing the page.");
      }
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
    console.log("applyWorkDay called");
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first");
      return;
    }
    this.applyDayClass('work-day');
    console.log("Applied work-day class to selected dates");
  }
  
  applyVacationDay() {
    console.log("applyVacationDay called");
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first");
      return;
    }
    this.applyDayClass('vacation-day');
    console.log("Applied vacation-day class to selected dates");
  }
  
  applySickDay() {
    console.log("applySickDay called");
    if (this.selectedDates.size === 0) {
      alert("Please select at least one day first");
      return;
    }
    this.applyDayClass('sick-day');
    console.log("Applied sick-day class to selected dates");
  }
  
  applyDayClass(className) {
    console.log(`applyDayClass called with class: ${className}`);
    console.log(`Selected dates count: ${this.selectedDates.size}`);
    
    this.selectedDates.forEach(date => {
      this.dayClassMap.set(date, className);
      console.log(`Set ${className} for date: ${date}`);
    });
    
    this.updateSelectedDaysDisplay();
    console.log("Updated selected days display");
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
    console.log("processBulkUpdate called with type:", type, "hours:", hours);
    
    const orgId = this.organizationIdValue || this.element.dataset.organizationId;
    const taskId = this.taskIdValue || this.element.dataset.taskId;
    
    console.log(`Organization ID: ${orgId}, Task ID: ${taskId}`);
    console.log(`Selected dates: ${Array.from(this.selectedDates).join(', ')}`);
    
    if (!orgId || !taskId) {
      console.error("Organization ID or Task ID is missing");
      alert("Error: Could not determine organization or task. Please refresh the page and try again.");
      return;
    }
    
    const url = `/organizations/${orgId}/tasks/${taskId}/task_timetrackings/bulk_update`;
    console.log("Bulk update URL:", url);
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    
    if (!csrfToken) {
      console.error("CSRF token not found");
      alert("Error: CSRF token not found. Please refresh the page and try again.");
      return;
    }
    
    // Convert selected dates to entries with type information
    const entries = Array.from(this.selectedDates).map(date => ({
      date: date,
      type: type,
      hours: hours,
      delete: type === 'delete'
    }));
    
    console.log("Prepared entries:", entries);
    
    if (entries.length === 0) {
      alert("No dates selected. Please select at least one date.");
      return;
    }
    
    console.log(`Sending ${entries.length} entries to ${url}`);
    const requestBody = JSON.stringify({ entries: entries });
    console.log("Request body:", requestBody);
    
    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ entries: entries })
    })
    .then(response => {
      console.log("Response status:", response.status);
      if (!response.ok) {
        console.error("Server returned error status:", response.status);
      }
      return response.json();
    })
    .then(data => {
      console.log("Response data:", data);
      
      if (data.error) {
        console.error("Error returned from server:", data.error);
        alert(`Error: ${data.error}`);
        return;
      }
      
      const successCount = data.success?.length || 0;
      const errorCount = data.error?.length || 0;
      
      console.log(`Success count: ${successCount}, Error count: ${errorCount}`);
      
      let message = `Successfully processed ${successCount} entries.`;
      if (errorCount > 0) {
        message += ` Failed to process ${errorCount} entries.`;
      }
      
      alert(message);
      this.hideBulkEditModal();
      
      if (this.calendar) {
        console.log("Refreshing calendar events");
        this.calendar.refetchEvents();
      } else {
        console.error("Calendar not found, cannot refresh events");
      }
      
      // Clear selections after successful update
      this.selectedDates.clear();
      this.updateSelectedDaysDisplay();
      
      if (this.calendar) {
        this.calendar.render();
      }
    })
    .catch(error => {
      console.error('Error processing bulk update:', error);
      alert('An error occurred while processing your request. Please try again.');
    });
  }
  
  submitBulkEdit() {
    console.log("submitBulkEdit called");
    const dayType = this.getSelectedDayType();
    console.log("Day type selected:", dayType);
    let hours = 0;
    
    switch(dayType) {
      case 'work-day':
        hours = 8;
        break;
      case 'vacation-day':
        hours = 8;
        break;
      case 'sick-day':
        hours = 8;
        break;
      default:
        hours = 0;
    }
    
    console.log(`Processing bulk update with type: ${dayType.replace('-day', '')}, hours: ${hours}`);
    this.processBulkUpdate(dayType.replace('-day', ''), hours);
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