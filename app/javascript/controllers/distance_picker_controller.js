import { Controller } from "@hotwired/stimulus"

// Lets the user pick a common race distance from a select, or choose "Otra…"
// to type one manually. The manual number field is always the source of truth
// for the submitted `run[distance]` value; the select is UI only.
export default class extends Controller {
  static targets = ["select", "manualField"]

  connect() {
    const current = parseFloat(this.manualFieldTarget.value)
    const match = this.#optionValues.find((value) => parseFloat(value) === current)

    if (match) {
      this.selectTarget.value = match
      this.#hideManualField()
    } else if (current > 0) {
      this.selectTarget.value = "other"
      this.#showManualField()
    } else {
      this.selectTarget.value = ""
      this.manualFieldTarget.value = ""
      this.#hideManualField()
    }
  }

  select() {
    if (this.selectTarget.value === "other") {
      this.#showManualField()
      this.manualFieldTarget.focus()
    } else {
      this.manualFieldTarget.value = this.selectTarget.value
      this.#hideManualField()
    }
  }

  get #optionValues() {
    return Array.from(this.selectTarget.options)
      .map((option) => option.value)
      .filter((value) => value !== "other")
  }

  #showManualField() {
    this.manualFieldTarget.hidden = false
  }

  #hideManualField() {
    this.manualFieldTarget.hidden = true
  }
}
