// ステップフォーム
document.addEventListener("turbo:load", () => {
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
    document.querySelectorAll('.error-message').forEach(el => el.remove());
    document.querySelectorAll('.error-container').forEach(el => el.remove());
    document.querySelectorAll('.input-error').forEach(el => {
      el.classList.remove('input-error', 'border-red-500');
    });
  };

  // エラーを表示する関数
  const showErrors = (errors, stepNum) => {
    clearErrors();
    
    let errorContainer = document.querySelector(`#step-${stepNum} .error-container`);
    if (!errorContainer) {
      errorContainer = document.createElement('div');
      errorContainer.className = 'error-container alert alert-error mb-4';
      const stepElement = document.querySelector(`#step-${stepNum}`);
      stepElement.insertBefore(errorContainer, stepElement.firstChild);
    }

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

  // ステップを検証する関数
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

  // ステップサークルの状態を更新
  const updateStepStatus = () => {
    for (let i = 1; i <= totalSteps; i++) {
      const circle = document.getElementById(`step-circle-${i}`);
      if (circle) {
        // 基本クラスをリセット
        circle.className = 'w-8 h-8 rounded-full border-2 flex items-center justify-center mb-2 font-bold';
        
        if (i < step) {
          // 完了済み - 緑背景+白文字+チェックマーク
          circle.classList.add("bg-primary", "text-white", "border-primary");
          circle.textContent = "✓";
        } else if (i === step) {
          // 現在のステップ - 白背景+緑枠線+数字
          circle.classList.add("border-primary", "text-primary", "bg-white");
          circle.textContent = i;
        } else {
          // 未到達 - グレー背景+数字
          circle.classList.add("bg-gray-300", "text-gray-500", "border-gray-300");
          circle.textContent = i;
        }
      }
    }
  };

  // ステップ表示を更新
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

  // 画像プレビュー機能
  const setupImagePreview = () => {
    const imageInput = document.querySelector('input[type="file"][accept="image/*"]');
    if (imageInput) {
      imageInput.addEventListener('change', (event) => {
        const file = event.target.files[0];
        if (file) {
          const reader = new FileReader();
          reader.onload = (e) => {
            let preview = document.getElementById('image-preview');
            if (!preview) {
              preview = document.createElement('div');
              preview.id = 'image-preview';
              preview.className = 'mt-4';
              event.target.parentElement.appendChild(preview);
            }
            preview.innerHTML = `
              <img src="${e.target.result}" 
                  class="max-w-full h-auto rounded-lg shadow-md" 
                  style="max-height: 300px;">
            `;
          };
          reader.readAsDataURL(file);
        }
      });
    }
  };

  // 確認画面への遷移
  const setupConfirmButton = () => {
    const confirmButton = document.querySelector('button[data-action*="goToConfirm"]');
    if (confirmButton) {
      confirmButton.addEventListener('click', async (event) => {
        event.preventDefault();
        
        const formData = getFormData();
        formData.append('step', 3);

        try {
          const response = await fetch('/products/validate_step', {
            method: 'POST',
            body: formData,
            headers: {
              'X-CSRF-Token': getCSRFToken()
            }
          });

          const result = await response.json();

          if (result.success) {
            window.location.href = '/products/confirm';
          } else {
            showErrors(result.errors || ['エラーが発生しました'], 3);
          }
        } catch (error) {
          console.error('Error during goToConfirm:', error);
          showErrors(['通信エラーが発生しました。もう一度お試しください。'], 3);
        }
      });
    }
  };

  // ナビゲーションボタンのイベント設定
  const bindNavigationButtons = () => {
    // 次へボタン
    document.querySelectorAll(".next-button").forEach((btn) => {
      btn.addEventListener("click", async (e) => {
        e.preventDefault();
        
        btn.disabled = true;
        btn.textContent = '検証中...';
        
        try {
          const isValid = await validateStep(step);
          
          if (isValid && step < totalSteps) {
            step++;
            updateStep();
          }
        } finally {
          btn.disabled = false;
          btn.textContent = '次へ';
        }
      });
    });

    // 戻るボタン
    document.querySelectorAll(".prev-button").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        if (step > 1) {
          step--;
          updateStep();
          clearErrors();
        }
      });
    });
  };

  // 初期化
  updateStep();
  bindNavigationButtons();
  setupImagePreview();
  setupConfirmButton();
});