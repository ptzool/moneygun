import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js'

// Register all Chart.js components
Chart.register(...registerables)

export default class extends Controller {
  static targets = ["weeklyTotal", "chart"]

  connect() {
    this.refreshStats()
    this.initializeChartIfAvailable()
    
    // Set up mutation observer to detect when time entries are added/updated
    this.setupMutationObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
    
    if (this.chart) {
      this.chart.destroy()
    }
  }

  refreshStats() {
    // This method will be called when time entries change
    // We can update any statistics here
    
    // For now, we just make sure the UI gets updated
    this.dispatch("refresh")
  }

  setupMutationObserver() {
    // Watch for changes to task timetrackings (added, updated, removed)
    const container = document.querySelector('#task_timetrackings') || document.body
    
    this.observer = new MutationObserver((mutations) => {
      let shouldRefresh = false
      
      mutations.forEach(mutation => {
        // Look for added or removed nodes that might be time entries
        if (mutation.type === 'childList' && 
           (mutation.addedNodes.length > 0 || mutation.removedNodes.length > 0)) {
          shouldRefresh = true
        }
      })
      
      if (shouldRefresh) {
        this.refreshStats()
      }
    })
    
    this.observer.observe(container, { 
      childList: true,
      subtree: true
    })
  }

  initializeChartIfAvailable() {
    if (this.hasChartTarget) {
      this.initializeChart()
    }
  }

  initializeChart() {
    const ctx = this.chartTarget.getContext('2d')
    
    // Get data from the element's data attributes
    const labels = JSON.parse(this.chartTarget.dataset.labels || '[]')
    const data = JSON.parse(this.chartTarget.dataset.values || '[]')
    
    this.chart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Hours Tracked',
          data: data,
          backgroundColor: 'rgba(79, 70, 229, 0.6)',
          borderColor: 'rgba(79, 70, 229, 1)',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                return `${context.parsed.y.toFixed(1)} hours`
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return value + 'h'
              }
            }
          }
        }
      }
    })
  }
}