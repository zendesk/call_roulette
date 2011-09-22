CallRoulette::Application.routes.draw do
  post "calls/create"
  post "calls/flow"
  post "calls/exception"
  get "dashboard/stats"
  root :to => "dashboard#index"
end
