import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    this.initialize()
    this.addEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
  }

  initialize() {
    this.menu = this.element
    this.isVisible = false
    this.currentX = 0
    this.currentY = 0
    this.contextTarget = null
  }

  addEventListeners() {
    this.hideMenuBound = this.hideMenu.bind(this)
    document.addEventListener('click', this.hideMenuBound)
    document.addEventListener('contextmenu', this.hideMenuBound)
    document.addEventListener('keydown', this.handleEscapeBound = this.handleEscape.bind(this))
    window.addEventListener('resize', this.hideMenuBound)
    window.addEventListener('scroll', this.hideMenuBound)
  }

  removeEventListeners() {
    document.removeEventListener('click', this.hideMenuBound)
    document.removeEventListener('contextmenu', this.hideMenuBound)
    document.removeEventListener('keydown', this.handleEscapeBound)
    window.removeEventListener('resize', this.hideMenuBound)
    window.removeEventListener('scroll', this.hideMenuBound)
  }

  showMenu(event) {
    // Prevent default context menu
    event.preventDefault()
    
    // Set position data
    this.currentX = event.clientX
    this.currentY = event.clientY
    this.contextTarget = event.target
    
    // Store click date if it comes from calendar
    if (event.detail && event.detail.date) {
      this.clickDate = event.detail.date
    }
    
    // Position and show menu
    this.positionMenu()
    this.menu.classList.remove('hidden')
    this.isVisible = true
    
    // Dispatch an event to notify other components
    this.element.dispatchEvent(new CustomEvent('context-menu:opened', {
      bubbles: true,
      detail: { 
        x: this.currentX,
        y: this.currentY,
        target: this.contextTarget,
        clickDate: this.clickDate
      }
    }))
    
    return false
  }

  hideMenu() {
    if (this.isVisible) {
      this.menu.classList.add('hidden')
      this.isVisible = false
      this.contextTarget = null
      
      // Dispatch an event to notify other components
      this.element.dispatchEvent(new CustomEvent('context-menu:closed', {
        bubbles: true
      }))
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape' && this.isVisible) {
      this.hideMenu()
    }
  }

  positionMenu() {
    const menuWidth = this.menu.offsetWidth
    const menuHeight = this.menu.offsetHeight
    const windowWidth = window.innerWidth
    const windowHeight = window.innerHeight
    
    // Check if menu goes outside viewport
    let x = this.currentX
    let y = this.currentY
    
    if (x + menuWidth > windowWidth) {
      x = windowWidth - menuWidth - 5
    }
    
    if (y + menuHeight > windowHeight) {
      y = windowHeight - menuHeight - 5
    }
    
    this.menu.style.left = `${x}px`
    this.menu.style.top = `${y}px`
  }

  getClickPosition() {
    return {
      x: this.currentX,
      y: this.currentY,
      target: this.contextTarget,
      date: this.clickDate
    }
  }
}