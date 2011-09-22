Call Roulette
=============

Sample Rails 3 app using [call_center](https://github.com/zendesk/call_roulette)

Overview
--------

Call Roulette is like Chat Roulette but with calls. People call in and are connected to random people. They can "next" their call buddy by pressing '*' until they've talked to their heart's content.

Requirements
------------

This app requires that you have a [Twilio](http://twilio.com) account set up and you have its `TWILIO_ACCOUNT_SID` and `TWILIO_AUTH_TOKEN` set up in your environment variables.

You will also need to set up a Twilio number that points to your app (being sure to replace call-roulette with the name of your Heroku app):

    Request URL: http://call-roulette.herokuapp.com/calls/create
    Fallback URL: http://call-roulette.herokuapp.com/calls/exception
    Status Callback URL: http://call-roulette.herokuapp.com/calls/flow?event=hang_up

Usage
-----

This app can be deployed to Heroku in the following steps:

    # Cedar stack allows us to run multiple processes
    heroku create --stack cedar

    # First deploy
    git push heroku master

    # Set up required variables
    heroku config:add TWILIO_ACCOUNT_SID=...
    heroku config:add TWILIO_AUTH_TOKEN=...
    heroku config:add TWILIO_TUNNEL_URL=http://name-of-app.herokuapp.com
    heroku config:add CALL_ROULETTE_PHONE_NUMBER="(123) 456 7890"

    # Start background process that routes calls
    heroku scale web=1 clock=1

Non-heroku deploys can just:

    export=TWILIO_ACCOUNT_SID=...
    export=TWILIO_AUTH_TOKEN=...
    export=TWILIO_TUNNEL_URL=http://name-of-app.herokuapp.com
    export=CALL_ROULETTE_PHONE_NUMBER="(123) 456 7890"
    
    foreman start
