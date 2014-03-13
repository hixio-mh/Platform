set :output, File.expand_path("./cron.log")

every 6.hours do
  command "coffee #{File.expand_path("../jobs/process_withdrawals.coffee")}"
end

every 15.minutes do
  command "coffee #{File.expand_path("../jobs/process_campaign_dates.coffee")}"
end