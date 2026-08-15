import { Controller } from "@hotwired/stimulus"

// Renders the visits-over-time chart. Chart.js is vendored and loaded as a
// deferred classic script, which the browser may execute after this module, so
// connect() cannot assume the global exists yet.
export default class extends Controller {
  static values = { labels: Array, data: Array }

  connect() {
    if (typeof Chart !== "undefined") {
      this.render()
    } else {
      this.onLoad = () => this.render()
      window.addEventListener("load", this.onLoad, { once: true })
    }
  }

  render() {
    // If Chart.js failed to load entirely, leave the canvas empty; the
    // aria-label still describes the data and the tables below carry it.
    if (typeof Chart === "undefined" || this.chart) return

    this.chart = new Chart(this.element, {
      type: "line",
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: "Visits",
          data: this.dataValue,
          fill: false,
          borderColor: "rgb(75, 192, 192)",
          backgroundColor: "rgba(75, 192, 192, 0.5)",
          tension: 0.1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: { y: { beginAtZero: true, ticks: { precision: 0 } } },
        plugins: {
          legend: { display: false },
          tooltip: { callbacks: { label: (context) => `Visits: ${context.raw}` } }
        }
      }
    })
  }

  disconnect() {
    if (this.onLoad) window.removeEventListener("load", this.onLoad)
    this.chart?.destroy()
    this.chart = null
  }
}
