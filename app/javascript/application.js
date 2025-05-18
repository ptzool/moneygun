// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

// Fallback for FullCalendar global access
document.addEventListener('DOMContentLoaded', function() {
  // Check if FullCalendar is loaded via CDN
  if (window.FullCalendar) {
    console.log("FullCalendar is loaded via CDN");
  } else {
    console.warn("FullCalendar is not loaded. Calendar functionality may not work correctly.");
  }
  
  // Initialize any modals that might be on the page
  document.querySelectorAll('.modal').forEach(modal => {
    const closeButtons = modal.querySelectorAll('.btn-close, [data-action*="hideModal"]');
    closeButtons.forEach(button => {
      button.addEventListener('click', () => {
        modal.classList.remove('show');
        modal.style.display = 'none';
      });
    });
  });
});
