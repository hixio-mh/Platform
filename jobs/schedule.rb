set :output, "./cron.log"

every 6.hours do
  command "coffee ../jobs/process_withdrawals.coffee"
end
