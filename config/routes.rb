# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :ruby do
    resources :outdated_gems, only: :show
  end
end
