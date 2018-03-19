Rails.application.routes.draw do
  devise_for :managers
  resources :tours, only: [:show, :index]
  namespace :admin do
    resources :awards
    resources :companies
    resources :managers
    resources :booking_dates
    resources :tours
    # admin dashboard root page (admin_tours)
    root to: "tours#index"
  end
  get   'booking_dates/book/:id',         to: 'booking_dates#book', as: "booking"
  put   'booking_dates/signup/:id',       to: 'booking_dates#signup'
  patch 'booking_dates/signup/:id',       to: 'booking_dates#signup'
  put   'admin/booking_dates/signup/:id', to: 'admin/booking_dates#signup'
  patch 'admin/booking_dates/signup/:id', to: 'admin/booking_dates#signup'
  put   'admin/booking_dates/cancel/:id', to: 'admin/booking_dates#cancel'
  patch 'admin/booking_dates/cancel/:id', to: 'admin/booking_dates#cancel'
  root to: "tours#index"
  # default route for non-existent pages to avoid errors
  # get "*path" => 'tours#index'
  # breaks active storage links - done to prevent 404 when mistype page
  # get '*path', to: redirect('/tours')
  # put '*path', to: redirect('/tours')
  # patch '*', to: 'tours#index', to: redirect('/tours')
end
