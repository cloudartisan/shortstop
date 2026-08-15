import { Controller } from "@hotwired/stimulus"

// Copies the short link to the clipboard and confirms it actually happened.
// The previous inline version used document.execCommand("copy" ) and ignored
// its return value, so the button reported success even when nothing copied.
export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    const original = this.buttonTarget.textContent

    try {
      await navigator.clipboard.writeText(this.sourceTarget.value)
      this.flash("Copied!", "btn-success", original)
    } catch {
      this.sourceTarget.select()
      this.flash("Press Ctrl+C", "btn-warning", original)
    }
  }

  flash(message, variant, original) {
    const button = this.buttonTarget
    button.textContent = message
    button.classList.remove("btn-outline-primary")
    button.classList.add(variant)

    setTimeout(() => {
      button.textContent = original
      button.classList.remove(variant)
      button.classList.add("btn-outline-primary")
    }, 2000)
  }
}
