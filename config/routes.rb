# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :ruby do
    resources :outdated_gems, only: :show
    resources :abandoned_gems, only: :show
  end

  namespace :webhooks do
    post 'ruby_gems' => 'ruby_gems#create'
  end
end
