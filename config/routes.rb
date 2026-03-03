Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  # Root — redirect based on role
  authenticated :user, ->(u) { u.admin? } do
    root to: 'manage/submissions#index', as: :admin_root
  end
  authenticated :user, ->(u) { u.creator? } do
    root to: 'portal/dashboard#index', as: :creator_root
  end
  root to: redirect('/users/sign_in')

  # Creator Portal
  namespace :portal do
    root to: 'dashboard#index'
    resources :submissions do
      member do
        patch :submit_for_review
      end
    end
    resources :sales, only: [:index]
    resources :royalties, only: [:index, :show]
    resources :messages, only: [:index, :create] do
      collection do
        get :submission_thread
      end
    end
  end

  # Admin Panel
  namespace :manage do
    root to: 'submissions#index'
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
  end
end
