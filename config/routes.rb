Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Auth
      post   "auth/login",                    to: "auth#login"
      post   "auth/forgot_password",          to: "auth#forgot_password"
      get    "dashboard",                      to: "dashboard#index"
      get    "auth/me",                       to: "auth#me"
      delete "auth/logout",                   to: "auth#logout"
      get    "auth/setup_password/validate",  to: "password_setups#validate"
      post   "auth/setup_password",           to: "password_setups#setup"

      # Notificações
      resources :notifications, only: [:index] do
        collection { patch :mark_all_read }
        member     { patch :mark_read }
      end

      resources :access_logs,   only: [:index]
      resources :announcements, only: [:index, :show, :create, :update, :destroy]
      get "agenda", to: "agenda#index"

      # Admin / Pedagógica
      resources :users
      resources :user_types
      resources :cities, only: [:index]
      resources :students
      resources :careers
      resources :courses do
        resources :subjects, only: [:index, :create, :destroy]
        resources :turmas,   shallow: true
      end
      resources :subjects, only: [:index, :create, :show, :update, :destroy]
      resources :turmas do
        resources :class_days, only: [:index, :create, :update, :destroy],
                  controller: "turma_class_days"
      end
      resources :enrollments
      resources :contracts, only: [:index, :show, :create, :update]
      resources :events do
        resources :registrations, only: [:index, :create, :destroy],
                  controller: "event_registrations"
        resources :lotes, only: [:index, :create, :update, :destroy],
                  controller: "event_lotes"
        member do
          get  :subjects,      to: "event_subjects#index"
          post :sync_subjects, to: "event_subjects#sync"
        end
      end
      patch "event_registrations/checkin", to: "event_registrations#checkin"
      patch "event_registrations/:id/undo_checkin", to: "event_registrations#undo_checkin"
      resources :topics
      resources :lessons
      resources :lesson_pdfs, only: [:index, :create, :destroy]

      # Professor namespace
      namespace :professor do
        get "dashboard", to: "dashboard#index"
        resources :turmas, only: [:index, :show] do
          member { get :students }
        end
        resources :materials
        resources :subjects, only: [:index]
        resources :event_materials, only: [:index, :create, :destroy]
        resources :questions, only: [:index, :show, :update] do
          member { patch :answer }
        end
      end

      # Aluno namespace
      namespace :aluno do
        get "dashboard", to: "dashboard#index"
        resources :questions,           only: [:index, :create]
        resources :lesson_completions,  only: [:index, :create, :destroy]
        resources :event_registrations, only: [:index]
        resources :event_materials,     only: [:index]
        resources :lessons,             only: [:index]
        resources :materials,           only: [:index]
        resources :lesson_pdfs,        only: [] do
          member { get :download }
        end
        resources :lessons, only: [] do
          member { get :video_token, controller: "video_tokens" }
        end
      end
    end
  end
end