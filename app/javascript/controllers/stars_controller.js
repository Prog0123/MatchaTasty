// 星の数で評価を行うコントローラー
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "display"];
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
        // アクティブな状態
        star.classList.remove("text-gray-400", "opacity-30", "grayscale");
        if (symbol === "★" || symbol === "⭐") {
          star.classList.add("text-yellow-400"); // 星は黄色
        } else {
          // 絵文字の場合は透明度とフィルターで制御
          star.classList.add("opacity-100");
        }
      } else {
        // 非アクティブな状態
        star.classList.remove("text-yellow-400", "opacity-100");
        if (symbol === "★" || symbol === "⭐") {
          star.classList.add("text-gray-400"); // 星は灰色
        } else {
          // 絵文字の場合は透明度を下げる + グレースケール
          star.classList.add("opacity-30", "grayscale");
        }
      }
    });
    // 数値表示を更新
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = value;
      
      // 数値に応じて色を変更（オプション）
      this.displayTarget.classList.remove("text-gray-700", "text-red-600", "text-yellow-600", "text-green-600");
      if (value === 0) {
        this.displayTarget.classList.add("text-gray-700");
      } else if (value <= 2) {
        this.displayTarget.classList.add("text-red-600");
      } else if (value === 3) {
        this.displayTarget.classList.add("text-yellow-600");
      } else {
        this.displayTarget.classList.add("text-green-600");
      }
    }
  }
}
