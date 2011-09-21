class Call < ActiveRecord::Base
  include CallCenter

  call_flow :state, :initial => :initial do
    state :initial do
      event :incoming_call, :to => :greeting
    end

    state :greeting do
      event :greeted, :to => :waiting
    end

    state :waiting do
      event :put_in_conference, :to => :in_conference
      event :time_out, :to => :timed_out
    end

    state :in_conference do
      event :cleanup, :to => :greeting
    end

    state any do
      event :hang_up, :to => :ended
    end

    on_render(:greeting) do |call, x|
      x.Say "Please wait while we find someone for you to talk to"
      x.Redirect flow_url(:greeted)
    end

    on_render(:waiting) do |call, x|
      HOLD_MUSIC.sort_by { rand }.each do |url|
        x.Play url
      end
      x.Say "You've been waiting way to long! Goodbye"
      x.Hangup
    end

    on_render(:in_conference) do |call, x|
      conference = Conference.new(conference_name)
      other_call = conference.other(call)
      x.Say "You are talking to #{other_call.location}... Press star to skip."
      x.Dial :hangupOnStar => true do
        x.Conference conference_name, :endConferenceOnExit => true
      end
      x.Redirect flow_url(:cleanup)
    end

    on_render(:timed_out) do |call, x|
      x.Say "Sorry we couldn't find someone for you. Please call back later and try again"
    end

    on_flow_to(:waiting) do |call, transition|
      call.update_attributes(:waiting_at => Time.now)
    end

    on_flow_to(:ended) do |call, transition|
      call.update_attributes(:ended_at => Time.now)
    end
  end

  # ===============
  # = Call Center =
  # ===============

  def run(event)
    send(event)
    render
  end

  def flow_url(event)
    params = {
      :call_id => self.id,
      :event => event.to_s
    }

    uri = URI.join(ENV['TWILIO_TUNNEL_URL'], "calls/flow")
    uri.query = params.to_query
    uri.to_s
  end

  def redirect_to(event, *args)
    account.calls.get(self.call_sid).update({:url => flow_url(event)})
  end

  def wait_time
    Time.now - (self.waiting_at || self.created_at)
  end

  # ========
  # = REST =
  # ========

  def account
    client.account
  end

  def client
    self.class.client
  end

  def self.client
    @client ||= Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  end

  # ===========
  # = Routing =
  # ===========

  MAX_WAIT_TIME = 60
  HOLD_MUSIC = [
    "http://com.twilio.music.classical.s3.amazonaws.com/MARKOVICHAMP-Borghestral.mp3",
    "http://com.twilio.music.classical.s3.amazonaws.com/Mellotroniac_-_Flight_Of_Young_Hearts_Flute.mp3",
    "http://com.twilio.music.classical.s3.amazonaws.com/ith_chopin-15-2.mp3",
    "http://com.twilio.music.classical.s3.amazonaws.com/oldDog_-_endless_goodbye_%28instr.%29.mp3",
    "http://com.twilio.music.classical.s3.amazonaws.com/ClockworkWaltz.mp3",
    "http://com.twilio.music.classical.s3.amazonaws.com/BusyStrings.mp3",
    "http://com.twilio.music.classical.s3.amazonaws.com/ith_brahms-116-4.mp3"
  ].freeze

  serialize :conference_history, Array

  def can_connect?(call)
    !conference_history.include?(call.from)
  end

  def call_conference_name(call)
    [self.call_sid, call.call_sid].sort.join('::')
  end

  def connect(call)
    self.conference_name = call_conference_name(call)
    Rails.logger.info "Creating conference: #{self.conference_name}"
    self.conference_history << call.from
    self.save!
    self.redirect_and_put_in_conference!
  end

  def location
    unless Carmen.countries.detect { |title, abbr| abbr == self.caller_country }
      return "an unknown caller"
    end
    if caller_states = Carmen::states(self.caller_country)
      title_and_abbreviation = caller_states.detect { |title, abbr| abbr == self.caller_state }
      if title_and_abbreviation
        return "someone in #{self.caller_city}, #{title_and_abbreviation.first}"
      end
    end
    return "someone in #{self.caller_city}, #{self.caller_state}"
  end

  def self.connect_random_strangers
    not_routed = []
    Call.where("state = ?", "waiting").order('RANDOM()').in_groups_of(2) do |group|
      group.compact!
      if group.count == 2
        c1, c2 = group
        if c1.can_connect?(c2) && c2.can_connect?(c1)
          c1.connect(c2)
          c2.connect(c1)
        else
          not_routed << c1 << c2
        end
      else
        group.each { |c| not_routed << c }
      end
    end

    not_routed.each do |call|
      Rails.logger.info "Call #{call.id}: #{call.wait_time}"
      if call.wait_time > MAX_WAIT_TIME
        Rails.logger.info "Timing out: #{call.id}"
        call.redirect_and_time_out!
      end
    end
  end

  class Conference
    def initialize(conference_name)
      @a, @b = conference_name.split('::')
    end

    def other(call)
      call.call_sid == @a ? Call.find_by_call_sid(@b) : Call.find_by_call_sid(@a)
    end
  end
end
