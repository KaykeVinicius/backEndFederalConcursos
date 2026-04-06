Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Auth
      post   "auth/login", to: "auth#login"
      get    "auth/me",    to: "auth#me"

      # Admin / Pedagógica
      resources :users
      resources :students
      resources :careers
      resources :courses do
        resources :subjects, shallow: true
        resources :turmas,   shallow: true
      end
      resources :subjects, only: [:index, :create]
      resources :turmas
      resources :enrollments
      resources :contracts, only: [:index, :show, :create, :update]
      resources :events
      resources :topics
      resources :lessons
      resources :lesson_pdfs, only: [:index, :create, :destroy]

      # Professor namespace
      namespace :professor do
        get "dashboard", to: "dashboard#index"
        resources :turmas,    only: [:index, :show]
        resources :materials
        resources :questions, only: [:index, :show, :update] do
          member { patch :answer }
        end
      end

      # Aluno namespace
      namespace :aluno do
        get "dashboard", to: "dashboard#index"
        resources :questions,          only: [:index, :create]
        resources :lesson_completions, only: [:index, :create, :destroy]
      end
    end
  end
end