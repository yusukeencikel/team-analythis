import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["departureFields"]

  connect() {
    this.toggleDepartureFields()
  }

  toggleDepartureFields() {
    const status = this.element.querySelector('#player_status').value
    if (status === 'inactive') {
      this.departureFieldsTarget.classList.remove('hidden')
    } else {
      this.departureFieldsTarget.classList.add('hidden')
    }
  }
}
