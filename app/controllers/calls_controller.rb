class CallsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :parse_params, :except => [:index]
  before_filter :find_and_update_call, :only => [:flow, :destroy]

  def index
  end

  def dashboard
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

  def create
    @call = Call.create!(@parsed_params)
    render :xml => @call.run(:incoming_call)
  end

  def flow
    render :xml => @call.run(params[:event])
  end

  def exception
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Goodbye.'
    end

    render :xml => response.text
  end

  private

  def parse_params
    pms = underscore_params
    @parsed_params = Call.column_names.inject({}) do |result, key|
      value = pms[key]
      result[key] = value unless value.blank?
      result
    end
  end

  def underscore_params
    params.inject({}) do |result, k_v|
      k, v = k_v
      result[k.underscore] = v
      result
    end
  end

  def find_call
    @call = (Call.find_by_id(params["call_id"]) || Call.find_by_call_sid(params['CallSid']))
  end

  def find_and_update_call
    find_call
    @call.update_attributes(@parsed_params)
  end
end