#!/usr/bin/env ruby
require 'adefy'

agent = Adefy::Agent.new host: "http://www.adefy.dev/",
                         apikey: "ytIicfVCHOSn9bp5kKvbEb6m"
## admin
agent.users.login username: "Dragme", password: "adefydev"
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
loop do
  sleep 0.20
  pub = pubs.sample
  begin
    hsh = agent_u.serve.serve(id: pub["apikey"], width: 400, height: 400, json: true)
    imprs = hsh["impression"]
    click = hsh["click"]
    Excon.get(imprs) if imprs && rand < 0.7
    Excon.get(click) if imprs && rand < 0.5
  rescue Excon::Errors::NotFound
    #
  end
  print line_clear
  print "Generating Traffic Like a Baws #{loader[i % loader.size]} : #{lyrics[(i / 5) % lyrics.size]}"
  i += 1
end