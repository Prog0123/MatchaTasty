import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
    shopName: String
  }

  connect() {
    if (this.hasLatitudeValue && this.hasLongitudeValue) {
      this.initMap()
    } else {
      this.element.innerHTML = '<p class="text-gray-500 text-center py-8">店舗の位置情報が登録されていません</p>'
    }
  }

  initMap() {
    // Google Maps APIの読み込みを待つ
    if (typeof google === 'undefined') {
      this.loadGoogleMapsScript()
      return
    }

    this.displayMap()
  }

  loadGoogleMapsScript() {
    const script = document.createElement('script')
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.getApiKey()}&callback=Function.prototype`
    script.async = true
    script.defer = true
    
    script.onload = () => {
      this.displayMap()
    }
    
    document.head.appendChild(script)
  }

  displayMap() {
    const position = {
      lat: this.latitudeValue,
      lng: this.longitudeValue
    }

    const map = new google.maps.Map(this.element, {
      center: position,
      zoom: 15,
      mapTypeControl: false,
      streetViewControl: false,
      fullscreenControl: true
    })

    const marker = new google.maps.Marker({
      position: position,
      map: map,
      title: this.shopNameValue || '店舗',
      animation: google.maps.Animation.DROP
    })

    const infoWindow = new google.maps.InfoWindow({
      content: `<div class="p-2"><strong>${this.shopNameValue || '店舗'}</strong></div>`
    })

    marker.addListener('click', () => {
      infoWindow.open(map, marker)
    })
  }

  getApiKey() {
    // メタタグからAPIキーを取得
    const meta = document.querySelector('meta[name="google-maps-api-key"]')
    return meta ? meta.content : ''
  }
}