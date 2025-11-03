import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    text: String,
    hashtags: Array
  }

  share(event) {
    event.preventDefault()
    
    // デバッグ用ログ
    console.log('Twitter Share:', {
      url: this.urlValue,
      text: this.textValue,
      hashtags: this.hashtagsValue
    })
    
    const params = new URLSearchParams({
      text: this.textValue,
      url: this.urlValue,
      hashtags: this.hashtagsValue.join(',')
    })
    
    const shareUrl = `https://twitter.com/intent/tweet?${params.toString()}`
    
    // ポップアップウィンドウのサイズと位置を計算
    const width = 550
    const height = 420
    const left = (window.screen.width - width) / 2
    const top = (window.screen.height - height) / 2
    
    // ポップアップでXのシェア画面を開く
    const popup = window.open(
      shareUrl,
      'twitter-share',
      `width=${width},height=${height},left=${left},top=${top},toolbar=no,menubar=no,scrollbars=yes,resizable=yes`
    )
    
    // ポップアップがブロックされた場合の処理
    if (!popup || popup.closed || typeof popup.closed === 'undefined') {
      alert('ポップアップがブロックされました。ブラウザの設定でポップアップを許可してください。')
    }
  }
}