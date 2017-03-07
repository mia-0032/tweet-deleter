require 'date'
require 'json'
require 'logger'
require 'twitter'

log = Logger.new(STDOUT)

# Downloaded tweet directory
tweet_dir = File.join ARGV[0], 'data/js/tweets'
log.info "Found tweets in #{tweet_dir}"

# start and end
target_months = (Date.parse(ARGV[1])..Date.parse(ARGV[2])).select {|d| d.day == 1}.map {|d| d.strftime '%Y_%m'}
log.info "Delete tweeted in #{target_months.join(',')}"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

target_months.each do |target_month|
  file_path = File.join tweet_dir, "#{target_month}.js"
  unless File.exist? file_path
    log.warn "Not Found #{file_path}, go to next month."
    next
  end

  log.warn "Delete tweets in #{file_path}"
  f = open(file_path, 'r')

  header = f.gets

  text = f.readlines.join('')
  json = JSON.parse text
  json.each do |tweet|
    tweet_id = tweet['id_str']
    log.info "Delete #{tweet_id}"
    begin
      client.destroy_status tweet_id
    rescue => e
      log.error "Failed to delete #{tweet_id}  message: #{e.message}"
    end
    sleep 1
  end
end
