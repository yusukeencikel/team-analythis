Rails.application.routes.draw do
  get 'dashboard', to: 'dashboards#show', as: 'dashboard'
  # 1. トップページのルート
  root 'dashboards#show'

  # 2. 基本的なリソースのルート
  # 【修正】playersリソースの定義を修正
  resources :players do
    collection do
      get "no_jersey_number"
      get 'retired'
      get :edit_all
      patch :update_all
      delete :destroy_all
    end
    member do
      get 'add_dummy_stats'
      post 'save_dummy_stats'
    end
  end
  resources :opponents
  resources :stadiums
  resources :best_orders do
    member do
      get :fetch # ベストオーダーのデータを取得するためのルート
    end
  end

  # 3. 試合と、それに紐づく成績のルート
  resources :games do
    member do
      patch :toggle_favorite
      post :ocr # NOTE: このルートが未使用であれば、将来的に削除を検討してください
    end

    # 投手成績
    resources :pitching_stats, only: [:index, :create] do
      collection do
        get :ocr_new
        post :ocr_create
      end
    end

    # 野手成績
    resource :batting_stats, only: [:show, :create], controller: 'batting_stats'

    # 野手成績OCR用
    namespace :batting_stats do
      resource :ocr, only: [:create], controller: '/batting_stats_ocrs'
    end
  end

  # 【修正】スコアボードOCR用のAPIエンドポイントをトップレベルに移動
  post 'games/ocr_score', to: 'games#ocr_score'

  # 4. 分析ページのルート
  get 'analytics', to: 'team_analytics#show', as: 'team_analytics'

  # 5. 設定関連のルート
  get 'settings', to: 'settings#index'
  namespace :settings do
    resources :csv_player_imports, only: [:new, :create]
  end
  resource :team, controller: 'settings', path: 'settings/team', only: [:show, :update], as: 'our_team_settings'
  resources :our_teams, only: [:edit, :update]
  resources :awards

  # 選手一括登録 (OCR) のルート
  resources :player_imports, only: [:index, :show, :edit, :update, :new, :create] do
    collection do
      get 'review', to: 'player_imports#show_confirm', as: 'review'
      post 'save', to: 'player_imports#save_confirm', as: 'save'
    end
  end
end