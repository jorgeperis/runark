import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["switch"]

  connect() {
    const stored = localStorage.getItem("theme")
    let isDark
    if (stored) {
      isDark = stored === "dark"
    } else {
      isDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    }
    this.switchTarget.checked = isDark
  }

  toggle() {
    const isDark = this.switchTarget.checked
    const theme = isDark ? "dark" : "light"
    localStorage.setItem("theme", theme)
    document.documentElement.dataset.theme = theme
  }
}
