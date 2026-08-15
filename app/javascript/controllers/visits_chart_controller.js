import { Controller } from "@hotwired/stimulus"

// Renders the visits-over-time chart. Chart.js is loaded from a pinned CDN in
// the layout; if it is unavailable the canvas simply stays empty and the
// aria-label still describes the data.
export default class extends Controller {
  static values = { labels: Array, data: Array }

  connect() {
    if (typeof Chart === "undefined") return

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
    this.chart?.destroy()
  }
}
