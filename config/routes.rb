# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :ruby do
    resources :outdated_gems, only: %i[index] do
      post :index, on: :collection
    end

    resources :abandoned_gems, only: %i[index] do
      post :index, on: :collection
    end

    resources :gems_licenser, only: %i[index show] do
      post :index, on: :collection
    end
  end

  namespace :web_hooks do
    post 'ruby_gems' => 'ruby_gems#create'
  end
end
