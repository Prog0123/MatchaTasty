document.addEventListener('turbo:load', function() {
  const mobileMenuButton = document.getElementById('mobile-menu-button');
  const mobileMenu = document.getElementById('mobile-menu');
  
  if (mobileMenuButton && mobileMenu) {
    
    // 既存のイベントリスナーを削除（重複防止）
    mobileMenuButton.removeEventListener('click', handleMenuButtonClick);
    
    // ハンバーガーメニューボタンのクリック処理
    mobileMenuButton.addEventListener('click', handleMenuButtonClick);

    // メニュー内のリンククリック時にメニューを閉じる
    const mobileMenuLinks = mobileMenu.querySelectorAll('a');
    mobileMenuLinks.forEach(link => {
      link.addEventListener('click', function() {
        closeMobileMenu();
      });
    });

    // メニュー外をクリックした時に閉じる
    document.addEventListener('click', handleOutsideClick);

    // ウィンドウサイズ変更時にモバイルメニューを閉じる
    window.addEventListener('resize', handleResize);

    // ハンバーガーボタンクリック処理
    function handleMenuButtonClick(event) {
      event.preventDefault();
      event.stopPropagation();
      toggleMobileMenu();
    }

    // 外部クリック処理
    function handleOutsideClick(event) {
      if (!mobileMenuButton.contains(event.target) && !mobileMenu.contains(event.target)) {
        closeMobileMenu();
      }
    }

    // リサイズ処理
    function handleResize() {
      if (window.innerWidth >= 768) { // md breakpoint
        closeMobileMenu();
      }
    }

    // メニューの開閉処理
    function toggleMobileMenu() {
      mobileMenu.classList.toggle('hidden');
      updateMenuIcon();
    }

    // メニューを閉じる
    function closeMobileMenu() {
      mobileMenu.classList.add('hidden');
      updateMenuIcon();
    }

    // アイコンの更新
    function updateMenuIcon() {
      const icon = mobileMenuButton.querySelector('svg path');
      if (mobileMenu.classList.contains('hidden')) {
        // ハンバーガーアイコン
        icon.setAttribute('d', 'M4 6h16M4 12h16M4 18h16');
      } else {
        // ×アイコン
        icon.setAttribute('d', 'M6 18L18 6M6 6l12 12');
      }
    }
  }
});

// Turboによるページ離脱時のクリーンアップ
document.addEventListener('turbo:before-cache', function() {
  const mobileMenu = document.getElementById('mobile-menu');
  if (mobileMenu) {
    mobileMenu.classList.add('hidden');
  }
});