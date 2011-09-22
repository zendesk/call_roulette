CallRoulette::Application.routes.draw do
  post "calls/create"
  post "calls/flow"
  post "calls/exception"
  get "calls/dashboard"
  root :to => "calls#index"
end
