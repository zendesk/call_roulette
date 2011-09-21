require 'spec_helper'

describe Call do
  before(:each) do
    Call.any_instance.stubs(:redirect_to)
  end

  after(:each) do
    Timecop.return
  end

  it "should route to random caller" do
    call = FactoryGirl.create(:waiting_call)
    call2 = FactoryGirl.create(:waiting_call)

    Call.connect_random_strangers

    call.reload.conference_name.should_not be_nil
    call2.reload.conference_name.should_not be_nil
    call.conference_name.should == call2.conference_name

    call.conference_history.should include(call2.from)
    call2.conference_history.should include(call.from)
  end

  it "should not route to same caller twice" do
    call = FactoryGirl.create(:waiting_call)
    call2 = FactoryGirl.create(:waiting_call)

    # =================
    # = First Pairing =
    # =================
    Call.connect_random_strangers

    call.reload.conference_name.should_not be_nil
    call2.reload.conference_name.should_not be_nil
    call.conference_name.should == call2.conference_name

    # ===========
    # = Cleanup =
    # ===========
    call.update_attributes(:conference_name => nil)
    call2.update_attributes(:conference_name => nil)

    call.conference_name.should be_nil
    call2.conference_name.should be_nil

    # ======================
    # = Additional Pairing =
    # ======================
    Call.connect_random_strangers

    call.reload.conference_name.should be_nil
    call2.reload.conference_name.should be_nil

    # ============
    # = New Call =
    # ============
    call3 = FactoryGirl.create(:waiting_call, :from => call.from)
    Call.connect_random_strangers

    call.reload.conference_name.should be_nil
    call2.reload.conference_name.should be_nil
    call3.reload.conference_name.should be_nil
  end

  it "should timeout call if max waiting time exceeded" do
    Call.any_instance.expects(:redirect_to).once
    Timecop.freeze
    call = FactoryGirl.create(:waiting_call)

    Timecop.travel(2.minutes.from_now)
    Call.connect_random_strangers
  end
end
