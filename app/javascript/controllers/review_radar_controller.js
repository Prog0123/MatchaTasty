// レーダーチャートを表示するためのコントローラー
import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static values = { data: Object }
  
  connect() {
    if (this.dataValue && Object.keys(this.dataValue).length > 0) {
      this.createChart()
    } else {
      console.warn("No chart data available")
    }
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  createChart() {
    const ctx = this.element.getContext("2d")
    
    this.chart = new Chart(ctx, {
      type: "radar",
      data: this.dataValue,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          r: {
            beginAtZero: true,
            min: 0,
            max: 5,
            ticks: { 
              stepSize: 1,
              font: {
                size: 12
              }
            },
            pointLabels: {
              font: {
                size: 14
              }
            }
          }
        },
        plugins: {
          legend: {
            position: 'top',
          }
        }
      }
    })
  }
}