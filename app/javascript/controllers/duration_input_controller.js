import { Controller } from "@hotwired/stimulus"

// Masks a single text field as a h:mm:ss duration, filling right-to-left like a
// microwave: typing "4530" shows "45:30", "14530" shows "1:45:30". The field is
// the source of truth for the submitted value; Run parses it server-side.
export default class extends Controller {
  connect() {
    this.element.value = this.#format(this.element.value)
    this.element.addEventListener("input", this.#onInput)
  }

  disconnect() {
    this.element.removeEventListener("input", this.#onInput)
  }

  #onInput = () => {
    this.element.value = this.#format(this.element.value)
  }

  #format(value) {
    let digits = value.replace(/\D/g, "").slice(-6)
    if (digits === "") return ""

    const groups = []
    while (digits.length > 2) {
      groups.unshift(digits.slice(-2))
      digits = digits.slice(0, -2)
    }
    groups.unshift(digits)

    return groups.join(":")
  }
}
