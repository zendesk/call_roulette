FactoryGirl.define do
  sequence :call_sid do |n|
    "call_sid_#{n}"
  end

  factory :call do
    account_sid                 'account_sid'
    to_zip                      '94102'
    from_state                  'CA'
    called                      '+14156250135'
    from_country                'US'
    caller_country              'US'
    called_zip                  '94102'
    direction                   'inbound'
    from_city                   'FREMONT'
    called_country              'US'
    caller_state                'CA'
    call_sid                    { FactoryGirl.generate(:call_sid) }
    called_state                'CA'
    from                        { Faker::Base.numerify("+1##########") }
    caller_zip                  '94555'
    from_zip                    '94555'
    application_sid             'application_sid'
    call_status                 'completed'
    to_city                     'SAN FRANCISCO'
    to_state                    'CA'
    to                          { Faker::Base.numerify("+1##########") }
    to_country                  'US'
    caller_city                 'FREMONT'
    api_version                 '2010-04-01'
    caller                      { |f| f.from }
    called_city                 'SAN FRANCISCO'

    factory :waiting_call do
      state 'waiting'
    end
  end
end
