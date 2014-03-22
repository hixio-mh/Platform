#!/usr/bin/env ruby
require 'adefy'

def timestamp
  Time.now.strftime("[%d/%m/%Y %H:%M:%S]")
end

@log = File.open("traffik.log", "a")
@log.sync = true

@admin_agent = Adefy::Agent.new host: "http://www.adefy.dev/",
                                apikey: "Nkv9tU54M9LLw9pSC8zIM8IB"

## admin
@admin_agent.users.login username: "admin", password: "sachercake"
@pubs = @admin_agent.publishers.all

## create a visitor agent
@agent_u = Adefy::Agent.new host: "http://www.adefy.dev/"
## Use the admin agent for requests as well, I have no idea what will happen...
#@agent_u = @admin_agent

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

def stack_thread(label, arra)
  Thread.new do
    loop do
      lnk = arra.shift
      begin
        @log.puts "#{timestamp} #{label} GET link #{lnk}"
        if lnk
          resp = Excon.get(lnk)
          @log.puts "#{timestamp} #{label} GET link #{lnk} [#{resp.status}]"
        end
        sleep 1.0
      rescue Excon::Errors::BadGateway
        @log.puts "#{timestamp} #{label} [WARN] Server appears to be down, waiting a few seconds"
        sleep 3.0
      # catch any other exception
      rescue Exception => ex
        @log.puts "#{timestamp} #{label} [ERROR] #{ex.inspect}\n#{ex.backtrace.join("\n")}"
        # and raise that mofo after we've logged it
        raise ex
      end
    end
  end
end

@click_thread = stack_thread("Click", click_stack)
@impressions_thread = stack_thread("Impression", impressions_stack)

@log.puts "#{timestamp} Started Traffic Generator"

loop do
  print line_clear
  pub = @pubs.sample

  begin
    hsh = @agent_u.serve.serve(apikey: pub["apikey"])

    imprs = hsh["impression"]
    click = hsh["click"]

    impressions_stack << imprs if imprs && rand < 0.7
    click_stack << click if click && rand < 0.5

  rescue Excon::Errors::BadGateway
    @log.puts "#{timestamp} Server appears to be down, waiting a few seconds"
    sleep 3.0
  rescue Excon::Errors::NotFound
    sleep 0.02
  end
  print "CLICK[#{"%03s" % click_stack.size}] IMPRESSION[#{"%03s" % impressions_stack.size}] Generating Traffic Like a Baws #{loader[i % loader.size]} : #{lyrics[(i / 5) % lyrics.size]}"
  i += 1
  sleep 0.20
end
