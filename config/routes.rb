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
  get 'setup/seed_buyers', to: 'setup#seed_buyers'

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

    # Notifications
    resources :notifications, only: [:index] do
      member do
        patch :mark_read
      end
      collection do
        patch :mark_all_read
        get :recent
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
        patch :advance_phase
      end
      resources :campaign_assets, only: [:index, :create, :destroy] do
        member do
          post :send_video
        end
      end
      resources :social_posts, only: [:index] do
        collection do
          post :schedule
        end
      end
      resources :scheduled_posts, only: [:show, :update, :destroy]
      resources :social_calendar, only: [:index]
      resources :social_performance, only: [:index]
      resources :personal_videos, only: [:create] do
        collection { get :queue_data }
      end
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
          get  :wizard
          patch :generate
          patch :wizard_generate
          patch :publish
          patch :unpublish
          patch :request_build
        end
      end

      # Fan CRM
      resources :contacts, only: [:index, :show, :update] do
        member do
          post :add_tag
          delete :remove_tag
          post :add_note
          post :enroll_drip
        end
        collection do
          post :import
        end
      end

      # Drip Campaigns
      resources :drip_campaigns do
        member do
          patch :toggle_status
          post :add_step
          delete :remove_step
          patch :update_step
        end
      end

      # Referral Program
      resources :referrals, only: [:index]

      # Creator Confirmations
      resources :confirmations, only: [:create]

      # Deliverables (creator review)
      resources :deliverables, only: [:index, :show] do
        member do
          patch :approve
          patch :request_revision
          post :add_note
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
      collection do
        post :bulk_advance
        post :bulk_message
      end
      member do
        patch :toggle_checklist_item
        patch :update_settings
        patch :set_phase
        patch :advance_phase
        post :duplicate
      end
      resources :campaign_assets, only: [] do
        member do
          patch :approve
          patch :request_changes
        end
      end
      resource :landing_page, only: [:show, :update] do
        member do
          get :builder
          get :wizard
          patch :generate
          patch :wizard_generate
          patch :toggle_notifications
        end
      end
      resources :page_submissions, only: [:index, :show]
      resources :live_events, only: [:index]
      resources :admin_deliverables do
        member do
          patch :revise
          post :add_note
        end
      end
    end
  end

  # Public landing pages
  get  'pages/:slug', to: 'pages#show', as: :public_page
  post 'pages/:slug/submit', to: 'pages#submit', as: :public_page_submit
end
