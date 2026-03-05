Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  # Root — redirect based on role
  authenticated :user, ->(u) { u.admin? } do
    root to: 'manage/dashboard#index', as: :admin_root
  end
  authenticated :user, ->(u) { u.creator? } do
    root to: 'portal/dashboard#index', as: :creator_root
  end
  root to: redirect('/users/sign_in')

  # One-time setup route — creates demo accounts
  get 'setup', to: 'setup#create_demo_accounts'

  # Creator Portal
  namespace :portal do
    root to: 'dashboard#index'
    # Submissions removed — campaigns are now created by admins directly
    resources :sales, only: [:index]
    resources :royalties, only: [:index, :show]
    resources :messages, only: [:index, :create] do
      collection do
        get :submission_thread
      end
    end

    # Campaign system
    resources :campaigns, only: [:show] do
      member do
        get  :links
        patch :update_links
        get  :ad_access
        patch :update_ad_access
        get  :logistics
        patch :update_logistics
        patch :complete_onboarding
      end
      resources :campaign_assets, only: [:index, :create, :destroy]
      resources :social_posts, only: [:index]
      resources :live_events, except: [:index, :show] do
        collection do
          get :studio
          get :recorder
        end
        member do
          patch :go_live
          patch :end_stream
        end
      end
      resource :landing_page, only: [:show, :update] do
        member do
          get  :builder
          patch :generate
          patch :publish
          patch :unpublish
          patch :request_build
        end
      end
    end
  end

  # Admin Panel
  namespace :manage do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#index'

    resources :authors do
      member { patch :toggle_status }
    end
    resources :books
    resources :users do
      member { patch :toggle_active }
    end
    resources :pages do
      member do
        get :builder
        patch :generate
        patch :toggle_publish
      end
    end
    get 'settings', to: 'settings#index'

    resources :submissions, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
        patch :mark_in_review
        post  :reply
      end
    end
    resources :portal_messages, only: [:index, :show, :create]
    resources :royalties do
      member do
        patch :mark_paid
      end
      collection do
        get  :rates
        get  :new_rate
        post :create_rate
      end
    end

    # Admin campaign management
    resources :campaigns, only: [:index, :show, :new, :create, :edit, :update] do
      member do
        patch :toggle_checklist_item
        patch :update_settings
      end
      resources :campaign_assets, only: [] do
        member do
          patch :approve
          patch :request_changes
        end
      end
      resource :landing_page, only: [:update] do
        member do
          get :builder
          patch :generate
          patch :toggle_notifications
        end
      end
      resources :page_submissions, only: [:index, :show]
      resources :live_events, only: [:index]
    end
  end

  # Public landing pages
  get  'pages/:slug', to: 'pages#show', as: :public_page
  post 'pages/:slug/submit', to: 'pages#submit', as: :public_page_submit
end
