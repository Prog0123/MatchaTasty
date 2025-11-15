import { Controller } from "@hotwired/stimulus"
// オートコンプリート機能を提供するStimulusコントローラー
// 商品名の入力時にリアルタイムで候補を表示し、選択を補助する
export default class extends Controller {
  // HTMLのdata属性でターゲット要素を指定
  // input: 検索入力欄
  // results: 候補を表示するドロップダウンエリア
  static targets = ["input", "results"]
  // HTMLのdata属性から値を取得
  // url: オートコンプリートAPIのエンドポイントURL
  static values = {
    url: String
  }
  // コントローラーが初期化された時に実行
  connect() {
    this.timeout = null
    this.selectedIndex = -1
  }
  // コントローラーが破棄される時に実行（クリーンアップ処理）
  disconnect() {
    this.clearTimeout()
  }
  // 入力欄に文字が入力された時に実行される検索メソッド
  search() {
    this.clearTimeout()
    
    const query = this.inputTarget.value.trim()
    // 2文字未満の場合は検索せず、候補を非表示にする
    if (query.length < 2) {
      this.hideResults()
      return
    }
    // 300ms後に検索を実行（連続入力時のAPIリクエスト過多を防ぐデバウンス処理）
    this.timeout = setTimeout(() => {
      this.fetchResults(query)
    }, 300) // 300msのデバウンス
  }
  // サーバーから検索候補を取得する非同期メソッド
  async fetchResults(query) {
    try {
      const url = `${this.urlValue}?query=${encodeURIComponent(query)}`
      const response = await fetch(url, {
        headers: {
          'Accept': 'application/json'
        }
      })
      // レスポンスが正常でない場合はエラーを投げる
      if (!response.ok) throw new Error('Network response was not ok')
      // JSONをパースして結果を表示
      const results = await response.json()
      this.displayResults(results)
    } catch (error) {
      // エラー発生時はコンソールにログを出力し、候補を非表示
      console.error('Autocomplete error:', error)
      this.hideResults()
    }
  }
  // 取得した候補をドロップダウンに表示するメソッド
  displayResults(results) {
    if (results.length === 0) {
      this.hideResults()
      return
    }
    // 各候補をHTML要素として生成
    // data-action: クリックとマウスホバー時のイベントを定義
    // data-index: キーボード操作用のインデックス
    // data-value: 選択時に入力欄に設定する値
    this.resultsTarget.innerHTML = results
      .map((result, index) => `
        <div class="autocomplete-item px-4 py-2 cursor-pointer hover:bg-base-200 transition-colors"
             data-action="click->autocomplete#select mouseenter->autocomplete#highlight"
             data-index="${index}"
             data-value="${this.escapeHtml(result)}">
          ${this.escapeHtml(result)}
        </div>
      `)
      .join('')
    // ドロップダウンを表示
    this.resultsTarget.classList.remove('hidden')
    this.selectedIndex = -1
  }
  // 候補ドロップダウンを非表示にするメソッド
  hideResults() {
    this.resultsTarget.classList.add('hidden')
    this.resultsTarget.innerHTML = ''
    this.selectedIndex = -1
  }
  // 候補がクリックされた時に実行されるメソッド
  select(event) {
    const value = event.currentTarget.dataset.value
    this.inputTarget.value = value
    this.hideResults()
    this.inputTarget.focus()
  }
  // マウスが候補の上に乗った時のハイライト処理
  highlight(event) {
    const items = this.resultsTarget.querySelectorAll('.autocomplete-item')
    items.forEach(item => item.classList.remove('bg-base-200'))
    event.currentTarget.classList.add('bg-base-200')
    this.selectedIndex = parseInt(event.currentTarget.dataset.index)
  }
  // キーボード操作を処理するメソッド（矢印キー、Enter、Escape）
  handleKeydown(event) {
    const items = this.resultsTarget.querySelectorAll('.autocomplete-item')
    // 候補が表示されていない場合は何もしない
    if (items.length === 0) return

    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateHighlight(items)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.updateHighlight(items)
        break
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0) {
          items[this.selectedIndex].click()
        }
        break
      case 'Escape':
        this.hideResults()
        break
    }
  }
  // キーボード選択時のハイライト表示を更新するメソッド
  updateHighlight(items) {
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('bg-base-200')
        item.scrollIntoView({ block: 'nearest' })
      } else {
        item.classList.remove('bg-base-200')
      }
    })
  }
  // デバウンス用タイマーをクリアするメソッド
  clearTimeout() {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }
  // XSS攻撃を防ぐためのHTMLエスケープメソッド
  // サーバーから取得したテキストを安全にHTMLに表示する
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  // 入力欄からフォーカスが外れた時に候補を非表示にするメソッド
  // 200ms遅延させることで、候補のクリックイベントが発火する時間を確保
  blur() {
    setTimeout(() => {
      this.hideResults()
    }, 200)
  }
}