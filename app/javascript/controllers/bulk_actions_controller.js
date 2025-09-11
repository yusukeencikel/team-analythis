import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editButton", "editPanel", "checkbox", "playerLink"]

  connect() {
    this.isEditing = false
  }

  enterEditMode() {
    this.isEditing = true
    this.updateDOM()
  }

  cancelEditMode() {
    this.isEditing = false
    this.uncheckAll()
    this.updateDOM()
  }

  updateDOM() {
    this.editButtonTarget.classList.toggle('hidden', this.isEditing)
    this.editPanelTarget.classList.toggle('hidden', !this.isEditing)
    this.checkboxTargets.forEach(checkbox => {
      checkbox.classList.toggle('hidden', !this.isEditing)
    })
    this.playerLinkTargets.forEach(link => {
      if (this.isEditing) {
        link.dataset.action = "click->bulk-actions#toggleCheck"
      } else {
        link.removeAttribute("data-action")
      }
    })
  }

  toggleCheck(event) {
    event.preventDefault()
    const checkbox = event.currentTarget.parentElement.querySelector('input[type="checkbox"]')
    checkbox.checked = !checkbox.checked
  }

  toggleAll(event) {
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = event.target.checked
    })
  }

  submitEdit() {
    const form = document.getElementById("bulk-edit-form")
    const selectedIds = this.selectedPlayerIds()

    if (selectedIds.length === 0) {
      alert("選手が選択されていません。")
      return
    }
    
    form.querySelectorAll('input[name="player_ids[]"]').forEach(input => input.remove())

    selectedIds.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "player_ids[]"
      input.value = id
      form.appendChild(input)
    })

    form.submit()
  }

  destroyAll() {
    const playerIds = this.selectedPlayerIds()

    if (playerIds.length === 0) {
      alert("選手が選択されていません。")
      return
    }

    if (confirm(`${playerIds.length}人の選手を削除します。よろしいですか？`)) {
      const form = document.getElementById("bulk-delete-form")
      form.innerHTML = '' // Clear previous hidden fields

      // _method hidden field for DELETE request
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = "delete"
      form.appendChild(methodInput)

      playerIds.forEach(id => {
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "player_ids[]"
        input.value = id
        form.appendChild(input)
      })

      const token = document.querySelector('meta[name="csrf-token"]').content
      const tokenInput = document.createElement("input")
      tokenInput.type = "hidden"
      tokenInput.name = "authenticity_token"
      tokenInput.value = token
      form.appendChild(tokenInput)

      form.submit()
    }
  }

  selectedPlayerIds() {
    return this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)
  }

  uncheckAll() {
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = false
    })
  }
}