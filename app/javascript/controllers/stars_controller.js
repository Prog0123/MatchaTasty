// 星の数で評価を行うコントローラー
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];
  static values = {
    name: String,
    symbol: String
  }

  connect() {
    this.update();
  }

  select(event) {
    const value = parseInt(event.target.dataset.value);
    this.inputTarget.value = value;
    this.update();
  }

  update() {
    const value = parseInt(this.inputTarget.value || 0);
    const symbol = this.symbolValue || "★";
    const stars = this.element.querySelectorAll(".star");

    stars.forEach((star, index) => {
      star.textContent = symbol;
      if (index < value) {
        star.classList.remove("text-gray-400");
        star.classList.add("text-yellow-400");
      } else {
        star.classList.add("text-gray-400");
        star.classList.remove("text-yellow-400");
      }
    });
  }
}
