// ステップフォーム
document.addEventListener("turbo:load", () => {
  let step = 1;
  const totalSteps = 3;

  const updateStepStatus = () => {
    for (let i = 1; i <= totalSteps; i++) {
      const circle = document.getElementById(`step-circle-${i}`);
      if (circle) {
        if (i < step) {
          circle.textContent = "✓";
          circle.classList.add("bg-primary", "text-white");
        } else {
          circle.textContent = i;
          circle.classList.remove("bg-primary", "text-white");
        }
      }
    }
  };

  const updateStep = () => {
    // 各ステップ表示切り替え
    document.querySelectorAll(".step-panel").forEach((el) => {
      el.classList.add("hidden");
    });
    const current = document.querySelector(`#step-${step}`);
    if (current) current.classList.remove("hidden");

    // プログレスバー更新
    const progressBar = document.getElementById("progress-bar");
    if (progressBar) {
      const percentage = ((step - 1) / (totalSteps - 1)) * 100;
      progressBar.style.width = `${percentage}%`;
    }

    // ステップラベルのハイライト
    document.querySelectorAll("#step-labels .step-label-text").forEach((el, idx) => {
      const isActive = idx + 1 === step;
      el.classList.toggle("font-bold", isActive);
      el.classList.toggle("text-primary", isActive);
    });

    // チェックマーク更新
    updateStepStatus();
  };

  const bindNavigationButtons = () => {
    // 次へボタンすべてにイベント追加
    document.querySelectorAll(".next-button").forEach((btn) => {
      btn.addEventListener("click", () => {
        if (step < totalSteps) {
          step++;
          updateStep();
        }
      });
    });

    // 戻るボタンすべてにイベント追加
    document.querySelectorAll(".prev-button").forEach((btn) => {
      btn.addEventListener("click", () => {
        if (step > 1) {
          step--;
          updateStep();
        }
      });
    });
  };

  updateStep();            // 初期表示
  bindNavigationButtons(); // イベント登録
});
