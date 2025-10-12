Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: "users/passwords"
  }

  get "homes/top"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Topページ
  root "homes#top"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  resources :products do
    collection do
      post :validate_step  # ステップ検証用のルート
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
