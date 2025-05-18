import { Controller } from "@hotwired/stimulus"
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'

export default class extends Controller {
  static targets = ["calendar", "modalTitle", "modalForm", "taskId", "membershipId", "date", "start", "end", "duration", "editForm", "deleteForm", "eventId", "deleteButton"]

  connect() {
    this.initializeCalendar()
    
    // Add global styles for tooltips and animations
    this.addGlobalStyles()
    
    // Set up context menu handler
    this.setupContextMenu()
  }
  
  addGlobalStyles() {
    // Create a style element if it doesn't exist yet
    let styleElement = document.getElementById('calendar-custom-styles');
    if (!styleElement) {
      styleElement = document.createElement('style');
      styleElement.id = 'calendar-custom-styles';
      document.head.appendChild(styleElement);
      
      // Add custom styles for the calendar
      styleElement.textContent = `
        .fc-event {
          cursor: pointer !important;
          transition: all 0.2s ease;
        }
        
        .fc-event:hover {
          box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
          transform: translateY(-2px);
        }
        
        .fc-toolbar-title {
          font-size: 1.25rem !important;
          font-weight: 600 !important;
        }
        
        .fc-button-primary {
          background-color: #6366f1 !important;
          border-color: #4f46e5 !important;
        }
        
        .fc-button-primary:hover {
          background-color: #4f46e5 !important;
          border-color: #4338ca !important;
        }
        
        .fc-button-active {
          background-color: #4338ca !important;
          border-color: #3730a3 !important;
        }
        
        .fc-today-button {
          text-transform: uppercase;
          font-size: 0.875rem !important;
        }
        
        .fc .fc-daygrid-day.fc-day-today {
          background-color: rgba(99, 102, 241, 0.1) !important;
        }
        
        .fc-popover {
          box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
          border: none !important;
          border-radius: 0.5rem;
        }
        
        .fc-popover .fc-popover-title {
          background-color: #6366f1;
          color: white;
          padding: 0.5rem;
          font-weight: 600;
        }
        
        .fc-h-event .fc-event-title {
          font-weight: 500;
          padding: 2px 4px;
        }
        
        .fc-theme-standard .fc-list-day-cushion {
          background-color: rgba(99, 102, 241, 0.1);
        }
        
        .calendar-container {
          min-height: 600px;
        }
        
        @keyframes scale-up {
          0% {
            transform: scale(0.8);
            opacity: 0;
          }
          100% {
            transform: scale(1);
            opacity: 1;
          }
        }
        
        .animate-scale-up {
          animation: scale-up 0.2s ease-out forwards;
        }
      `;
    }
  }
  
  disconnect() {
    if (this.calendar) {
      this.calendar.destroy();
      this.calendar = null;
    }
    
    // Clean up any event listeners
    const styleElement = document.getElementById('calendar-custom-styles');
    if (styleElement) {
      styleElement.remove();
    }
    
    this.cleanupContextMenu();
  }

  initializeCalendar() {
    const self = this
    const calendarEl = this.calendarTarget

    this.calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek'
      },
      height: 'auto',
      editable: true,
      selectable: true,
      selectMirror: true,
      dayMaxEvents: true,
      eventTimeFormat: {
        hour: '2-digit',
        minute: '2-digit',
        meridiem: 'short'
      },
      buttonText: {
        today: 'Today',
        month: 'Month',
        week: 'Week'
      },
      events: this.element.dataset.eventsUrl,
      select: function(info) {
        self.showAddModal(info.startStr, info.endStr)
      },
      eventClick: function(info) {
        self.showEditModal(info.event)
      },
      eventDrop: function(info) {
        self.handleEventDrop(info.event)
      },
      eventContent: function(arg) {
        let timeText = arg.timeText || '';
        
        // Create a custom event element with more details
        let titleEl = document.createElement('div')
        titleEl.className = 'fc-event-title'
        titleEl.innerHTML = arg.event.title || "Time Log"
        
        let timeEl = document.createElement('div')
        timeEl.className = 'fc-event-time'
        
        if (timeText) {
          timeEl.innerHTML = timeText
        } else if (arg.event.allDay) {
          timeEl.innerHTML = 'All day'
        } else {
          timeEl.innerHTML = 'No time set'
        }
        
        // Add duration if available
        if (arg.event.extendedProps && arg.event.extendedProps.duration_in_hours) {
          let durationEl = document.createElement('div')
          durationEl.className = 'fc-event-duration text-xs'
          durationEl.innerHTML = arg.event.extendedProps.duration_in_hours + ' hrs'
          
          return { domNodes: [titleEl, timeEl, durationEl] }
        }
        
        return { domNodes: [titleEl, timeEl] }
      },
      dateClick: function(info) {
        // When a date is clicked, we'll use this to trigger our context menu
        const customEvent = new CustomEvent('calendar:dateClick', {
          bubbles: true,
          detail: { date: info.dateStr }
        })
        self.element.dispatchEvent(customEvent)
      },
      eventDidMount: function(info) {
        // Add tooltips to events
        const duration = info.event.extendedProps.duration_in_hours || '';
        const memberName = info.event.extendedProps.member_name || '';
        
        const tooltip = `
          <div class="bg-gray-900 text-white p-2 rounded text-sm">
            <div><strong>Duration:</strong> ${duration} hours</div>
            <div><strong>Tracked by:</strong> ${memberName}</div>
            <div class="text-xs text-gray-300 mt-1">Click to edit</div>
          </div>
        `;
        
        new Tooltip(info.el, {
          title: tooltip,
          html: true,
          placement: 'top',
          trigger: 'hover',
          container: 'body'
        });
      }
    });

    this.calendar.render();
  }

  setupContextMenu() {
    this.contextMenuElement = document.getElementById('calendar-context-menu');
    if (!this.contextMenuElement) return;
    
    // Store reference to the current instance
    const self = this;
    
    // Set up event handlers for calendar cells
    this.element.addEventListener('calendar:dateClick', function(event) {
      // Hide any existing context menu
      if (self.contextMenuElement.classList.contains('hidden') === false) {
        self.contextMenuElement.classList.add('hidden');
      }
      
      // Set the clicked date for later use
      self.clickedDate = event.detail.date;
      
      // Position and show the context menu
      const mouseEvent = event.detail.jsEvent || window.event;
      if (mouseEvent) {
        self.contextMenuElement.style.left = `${mouseEvent.clientX}px`;
        self.contextMenuElement.style.top = `${mouseEvent.clientY}px`;
      } else {
        // If jsEvent is not available, position near the calendar
        const rect = self.calendarTarget.getBoundingClientRect();
        self.contextMenuElement.style.left = `${rect.left + 50}px`;
        self.contextMenuElement.style.top = `${rect.top + 50}px`;
      }
      
      self.contextMenuElement.classList.remove('hidden');
      
      // Prevent the default context menu
      event.preventDefault();
    });
    
    // Close context menu when clicking elsewhere
    document.addEventListener('click', this.closeContextMenuHandler = function(e) {
      if (!self.contextMenuElement.contains(e.target) && 
          !e.target.classList.contains('fc-day') &&
          !e.target.classList.contains('fc-daygrid-day-frame')) {
        self.contextMenuElement.classList.add('hidden');
      }
    });
    
    // Close on escape key
    document.addEventListener('keydown', this.escKeyHandler = function(e) {
      if (e.key === 'Escape') {
        self.contextMenuElement.classList.add('hidden');
      }
    });
  }
  
  cleanupContextMenu() {
    if (this.closeContextMenuHandler) {
      document.removeEventListener('click', this.closeContextMenuHandler);
    }
    
    if (this.escKeyHandler) {
      document.removeEventListener('keydown', this.escKeyHandler);
    }
  }

  showAddModalFromContext(event) {
    // Hide the context menu
    this.contextMenuElement.classList.add('hidden');
    
    // Use the stored clicked date
    if (this.clickedDate) {
      this.showAddModal(this.clickedDate);
    } else {
      this.showAddModal(new Date().toISOString().split('T')[0]);
    }
  }
  
  goToDate(event) {
    // Hide the context menu
    this.contextMenuElement.classList.add('hidden');
    
    // Go to the clicked date
    if (this.clickedDate) {
      this.calendar.gotoDate(this.clickedDate);
    }
  }

  showAddModal(startStr, endStr) {
    // Get a reference to the modal elements
    const addModal = this.element.querySelector('[data-time-calendar-target="addModal"]');
    if (!addModal) return;
    
    // Show the modal
    addModal.classList.remove('hidden');
    
    // Set the title and form action
    this.modalTitleTarget.textContent = "Add Time Entry";
    
    // Set default values
    this.dateTarget.value = startStr || new Date().toISOString().split('T')[0];
    
    const now = new Date();
    const startHour = now.getHours().toString().padStart(2, '0');
    const startMin = Math.floor(now.getMinutes() / 15) * 15;
    this.startTarget.value = `${startHour}:${startMin.toString().padStart(2, '0')}`;
    
    // Set end time to 1 hour later by default
    const later = new Date(now.getTime() + 60 * 60 * 1000);
    const endHour = later.getHours().toString().padStart(2, '0');
    const endMin = Math.floor(later.getMinutes() / 15) * 15;
    this.endTarget.value = `${endHour}:${endMin.toString().padStart(2, '0')}`;
    
    // Set default duration to 1 hour
    this.durationTarget.value = "1.0";
    
    // Focus on the first input field
    setTimeout(() => {
      this.startTarget.focus();
    }, 100);
  }

  showEditModal(event) {
    // Get a reference to the modal elements
    const editModal = this.element.querySelector('[data-time-calendar-target="editModal"]');
    if (!editModal) return;
    
    // Show the modal
    editModal.classList.remove('hidden');
    
    // Set up form for editing
    const editForm = this.editFormTarget;
    const deleteForm = this.deleteFormTarget;
    
    // Set the event ID in both forms
    this.eventIdTarget.value = event.id;
    deleteForm.querySelector('input[name="event_id"]').value = event.id;
    
    // Set the form action URLs
    const updateUrl = this.element.dataset.updateUrl.replace('__ID__', event.id);
    const deleteUrl = this.element.dataset.deleteUrl.replace('__ID__', event.id);
    
    editForm.action = updateUrl;
    deleteForm.action = deleteUrl;
    
    // Parse the event date and times
    const date = event.start ? event.start.toISOString().split('T')[0] : '';
    let startTime = '';
    let endTime = '';
    
    if (event.start && !event.allDay) {
      startTime = event.start.toTimeString().substr(0, 5);
    }
    
    if (event.end && !event.allDay) {
      endTime = event.end.toTimeString().substr(0, 5);
    }
    
    // Set form values
    this.element.querySelector('[data-time-calendar-target="date"]').value = date;
    this.element.querySelector('[data-time-calendar-target="start"]').value = startTime;
    this.element.querySelector('[data-time-calendar-target="end"]').value = endTime;
    
    // Set duration
    const duration = event.extendedProps.duration_in_hours || 1.0;
    this.element.querySelector('[data-time-calendar-target="duration"]').value = duration;
    
    // Show the delete button for edit mode
    this.deleteButtonTarget.classList.remove('hidden');
    
    // Focus on the duration field
    setTimeout(() => {
      this.element.querySelector('[data-time-calendar-target="duration"]').select();
    }, 100);
  }

  handleEventDrop(event) {
    const updateUrl = this.element.dataset.updateUrl.replace('__ID__', event.id);
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    
    if (csrfToken) {
      headers['X-CSRF-Token'] = csrfToken;
    }
    
    // Prepare the date from the event
    const newDate = event.start.toISOString().split('T')[0];
    
    fetch(updateUrl, {
      method: 'PATCH',
      headers: headers,
      body: JSON.stringify({
        task_timetracking: {
          date: newDate
        }
      })
    })
    .then(response => {
      if (!response.ok) {
        event.revert();
        throw new Error('Failed to update event');
      }
      return response.json();
    })
    .then(data => {
      // Show success message
      this.showToast('Time entry updated successfully');
    })
    .catch(error => {
      console.error('Error:', error);
      event.revert();
      this.showToast('Failed to update time entry', 'error');
    });
  }

  updateDuration() {
    const start = this.element.querySelector('[data-time-calendar-target="start"]').value;
    const end = this.element.querySelector('[data-time-calendar-target="end"]').value;
    const durationField = this.element.querySelector('[data-time-calendar-target="duration"]');
    
    if (start && end) {
      const startTime = new Date(`2000-01-01T${start}:00`);
      const endTime = new Date(`2000-01-01T${end}:00`);
      
      let durationInHours;
      
      if (endTime < startTime) {
        // Handle overnight shifts by adding 24 hours to end time
        const endTimeNextDay = new Date(endTime);
        endTimeNextDay.setDate(endTimeNextDay.getDate() + 1);
        durationInHours = (endTimeNextDay - startTime) / (1000 * 60 * 60);
      } else {
        durationInHours = (endTime - startTime) / (1000 * 60 * 60);
      }
      
      // Round to nearest quarter hour
      durationInHours = Math.round(durationInHours * 4) / 4;
      
      if (durationInHours > 0) {
        durationField.value = durationInHours.toFixed(2);
      }
    }
  }

  updateEndTime() {
    const start = this.element.querySelector('[data-time-calendar-target="start"]').value;
    const durationField = this.element.querySelector('[data-time-calendar-target="duration"]').value;
    const endField = this.element.querySelector('[data-time-calendar-target="end"]');
    
    if (start && durationField) {
      const startTime = new Date(`2000-01-01T${start}:00`);
      const durationInHours = parseFloat(durationField);
      
      if (!isNaN(durationInHours) && durationInHours > 0) {
        const durationInMs = durationInHours * 60 * 60 * 1000;
        const endTime = new Date(startTime.getTime() + durationInMs);
        
        const endHours = endTime.getHours().toString().padStart(2, '0');
        const endMinutes = endTime.getMinutes().toString().padStart(2, '0');
        
        endField.value = `${endHours}:${endMinutes}`;
      }
    }
  }

  delete(event) {
    if (!confirm('Are you sure you want to delete this time entry?')) {
      return;
    }
    
    const deleteForm = this.deleteFormTarget;
    const eventId = deleteForm.querySelector('input[name="event_id"]').value;
    const deleteUrl = this.element.dataset.deleteUrl.replace('__ID__', eventId);
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    
    if (csrfToken) {
      headers['X-CSRF-Token'] = csrfToken;
    }
    
    fetch(deleteUrl, {
      method: 'DELETE',
      headers: headers
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Failed to delete event');
      }
      
      // Hide modal
      this.hideModal();
      
      // Remove from calendar
      const event = this.calendar.getEventById(eventId);
      if (event) {
        event.remove();
      }
      
      // Show success message
      this.showToast('Time entry deleted successfully');
    })
    .catch(error => {
      console.error('Error:', error);
      this.showToast('Failed to delete time entry', 'error');
    });
  }

  submitForm(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    const url = form.action;
    const method = form.method.toUpperCase() === 'GET' ? 'GET' : 'POST';
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    
    const headers = {
      'Accept': 'application/json'
    };
    
    if (csrfToken) {
      headers['X-CSRF-Token'] = csrfToken;
    }
    
    fetch(url, {
      method: method,
      headers: headers,
      body: formData
    })
    .then(response => {
      if (!response.ok) {
        return response.json().then(data => {
          throw new Error(data.error || 'Failed to save time entry');
        });
      }
      return response.json();
    })
    .then(data => {
      // Hide the modal
      this.hideModal();
      
      // Refresh calendar
      this.calendar.refetchEvents();
      
      // Show success message
      this.showToast('Time entry saved successfully');
    })
    .catch(error => {
      console.error('Error:', error);
      this.showToast(error.message || 'Failed to save time entry', 'error');
    });
  }
  
  showToast(message, type = 'success') {
    // Create a toast notification element
    const toast = document.createElement('div');
    toast.className = `fixed bottom-4 right-4 px-4 py-2 rounded shadow-lg z-50 ${
      type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
    }`;
    toast.innerHTML = message;
    
    // Add to document
    document.body.appendChild(toast);
    
    // Remove after delay
    setTimeout(() => {
      toast.classList.add('opacity-0', 'transition-opacity', 'duration-500');
      setTimeout(() => {
        document.body.removeChild(toast);
      }, 500);
    }, 3000);
  }

  showModal(modalElement) {
    if (!modalElement) return;
    
    // Show the modal
    modalElement.classList.remove('hidden');
    
    // Add event listeners to close when clicking outside or pressing escape
    this.closeModalListener = (e) => {
      if (e.target === modalElement) {
        this.hideModal();
      }
    };
    
    this.escKeyListener = (e) => {
      if (e.key === 'Escape') {
        this.hideModal();
      }
    };
    
    document.addEventListener('click', this.closeModalListener);
    document.addEventListener('keydown', this.escKeyListener);
  }

  hideModal() {
    // Hide all modals
    const modals = this.element.querySelectorAll('.modal');
    modals.forEach(modal => {
      modal.classList.add('hidden');
    });
    
    // Remove event listeners
    if (this.closeModalListener) {
      document.removeEventListener('click', this.closeModalListener);
    }
    
    if (this.escKeyListener) {
      document.removeEventListener('keydown', this.escKeyListener);
    }
  }
}