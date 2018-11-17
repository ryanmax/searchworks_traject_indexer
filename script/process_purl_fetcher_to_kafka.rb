$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'traject'
require 'traject/readers/purl_fetcher_reader'
require 'traject/extractors/purl_fetcher_kafka_extractor'

require 'logger'
logger = Logger.new($stderr)
kafka = Kafka.new(ENV.fetch('KAFKA', 'localhost:9092').split(','), logger: logger)
state_file = File.expand_path('../tmp/searchworks_traject_indexer_last_run', __dir__)

File.open(state_file, 'w') { |f| f.puts Time.parse('1970-01-01T00:00:00') } unless File.exist? state_file

count = 0

File.open(state_file, 'r+') do |f|
  f.flock(File::LOCK_EX|File::LOCK_NB)

  last_date = f.read.strip

  Traject::PurlFetcherReader.new(nil, 'purl_fetcher.first_modified': last_date).each.each_slice(1000) do |reader|
    Traject::PurlFetcherKafkaExtractor.new(reader: reader, kafka: kafka, topic: ENV['KAFKA_TOPIC']).process!

    count += reader.length

    f.rewind
    f.truncate(0)
    f.puts(reader.last['latest_change'])
  end
end

kafka.deliver_message(nil, key: 'break', topic: ENV['KAFKA_TOPIC']) if count > 0
