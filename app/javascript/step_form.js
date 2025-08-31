// ステップフォーム
document.addEventListener("turbo:load", () => {
  // サーバーサイドからステップが指定されている場合はそれを使用
  let step = 1;
  const totalSteps = 3;

  // CSRFトークンを取得する関数
  const getCSRFToken = () => {
    const tokenElement = document.querySelector('meta[name="csrf-token"]');
    return tokenElement ? tokenElement.getAttribute('content') : null;
  };

  // フォームデータを取得する関数
  const getFormData = () => {
    const form = document.querySelector('form');
    return new FormData(form);
  };

  // エラー表示をクリアする関数
  const clearErrors = () => {
    // 既存のエラーメッセージを削除
    document.querySelectorAll('.error-message').forEach(el => el.remove());
    document.querySelectorAll('.error-container').forEach(el => el.remove());
    
    // input要素からエラークラスを削除
    document.querySelectorAll('.input-error').forEach(el => {
      el.classList.remove('input-error', 'border-red-500');
    });
  };

  // エラーを表示する関数
  const showErrors = (errors, stepNum) => {
    clearErrors();
    
    // ステップごとのエラー表示エリアを作成または取得
    let errorContainer = document.querySelector(`#step-${stepNum} .error-container`);
    if (!errorContainer) {
      errorContainer = document.createElement('div');
      errorContainer.className = 'error-container alert alert-error mb-4';
      const stepElement = document.querySelector(`#step-${stepNum}`);
      stepElement.insertBefore(errorContainer, stepElement.firstChild);
    }

    // エラーメッセージを表示
    const errorList = document.createElement('ul');
    errors.forEach(error => {
      const listItem = document.createElement('li');
      listItem.textContent = error;
      listItem.className = 'error-message';
      errorList.appendChild(listItem);
    });
    
    errorContainer.innerHTML = '';
    errorContainer.appendChild(errorList);

    // 該当するinput要素にエラースタイルを適用
    errors.forEach(error => {
      // エラーメッセージから対応するフィールドを特定してスタイル適用
      if (error.includes('商品名')) {
        const input = document.querySelector('input[name="product[name]"]');
        if (input) input.classList.add('input-error', 'border-red-500');
      }
      if (error.includes('店舗名')) {
        const input = document.querySelector('input[name="product[shop_name]"]');
        if (input) input.classList.add('input-error', 'border-red-500');
      }
      if (error.includes('カテゴリ')) {
        const input = document.querySelector('select[name="product[category]"]');
        if (input) input.classList.add('input-error', 'border-red-500');
      }
      if (error.includes('価格')) {
        const input = document.querySelector('input[name="product[price]"]');
        if (input) input.classList.add('input-error', 'border-red-500');
      }
    });
  };

  // ステップを検証する関数　次へボタン押下時に呼び出し
  const validateStep = async (stepNum) => {

    try {
      const formData = getFormData();
      formData.append('step', stepNum);

      const response = await fetch('/products/validate_step', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': getCSRFToken(),
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData
      });

      const result = await response.json();
      
      if (result.success) {
        clearErrors();
        return true;
      } else {
        showErrors(result.errors, stepNum);
        return false;
      }
    } catch (error) {
      console.error('Validation error:', error);
      alert('検証中にエラーが発生しました。');
      return false;
    }
  };

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
      btn.addEventListener("click", async (e) => {
        e.preventDefault();
        
        // ボタンを一時的に無効化
        btn.disabled = true;
        btn.textContent = '検証中...';
        
        try {
          // 現在のステップを検証
          const isValid = await validateStep(step);
          
          if (isValid && step < totalSteps) {
            step++;
            updateStep();
          }
        } finally {
          // ボタンを再有効化
          btn.disabled = false;
          btn.textContent = '次へ';
        }
      });
    });

    // 戻るボタンすべてにイベント追加
    document.querySelectorAll(".prev-button").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        if (step > 1) {
          step--;
          updateStep();
          clearErrors(); // 戻る時はエラーをクリア
        }
      });
    });
  };

  // 初期化
  updateStep();
  bindNavigationButtons();
});