class DashboardController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
  end

  def stats
    live_calls = {
      :waiting => Call.where("state = ?", "waiting"),
      :in_conference => Call.where("state = ?", "in_conference")
    }

    render :json => {
      :live_calls => live_calls,
      :live_calls_count => Call.where("state in (?)", ["waiting", "in_conference"]).count,
      :total_calls_count => Call.count
    }
  end
end