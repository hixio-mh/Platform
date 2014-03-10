#!/usr/bin/env ruby
require 'adefy'

agent = Adefy::Agent.new host: "http://www.adefy.dev/"

## admin
agent.users.login username: "admin", password: "sachercake"
pubs = agent.publishers.all

## create a visitor agent
agent_u = Adefy::Agent.new host: "http://www.adefy.dev/"

i = 0
loader = '|/-\\'
line_clear = "\r" + (" " * 80) + "\r"

lyrics = %w[
  they see me
  trafficing ads
  they hope that they gonna catch me as an airpush spy
  trying catch me as an airpush spy
  trying catch me as an airpush spy
  trying catch me as an airpush spy
  they trying
  they trying
]

click_stack = []
impressions_stack = []

Thread.abort_on_exception = true

def stack_thread(arra)
  Thread.new do
    loop do
      lnk = arra.shift
      begin
        Excon.get(lnk) if lnk
        sleep 0.20
      rescue Excon::Errors::BadGateway
        STDERR.puts "Clicks/Impressions Server appears to be down, waiting a few seconds"
        sleep 3.0
      end
    end
  end
end

stack_thread(click_stack)
stack_thread(impressions_stack)

loop do
  print line_clear
  pub = pubs.sample
  begin
    hsh = agent_u.serve.serve(id: pub["apikey"], width: 400, height: 400, json: true)
    imprs = hsh["impression"]
    click = hsh["click"]
    impressions_stack << imprs if imprs && rand < 0.7
    click_stack << click if click && rand < 0.5
  rescue Excon::Errors::BadGateway
    STDERR.puts "Server appears to be down, waiting a few seconds"
    sleep 3.0
  rescue Excon::Errors::NotFound
    sleep 0.02
  end
  print "Generating Traffic Like a Baws #{loader[i % loader.size]} : #{lyrics[(i / 5) % lyrics.size]}"
  i += 1
  sleep 0.20
end
