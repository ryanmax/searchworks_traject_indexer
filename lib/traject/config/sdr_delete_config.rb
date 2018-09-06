$LOAD_PATH << File.expand_path('../..', __dir__)

require 'traject'
require 'traject/readers/purl_fetcher_reader'
require 'traject/readers/purl_fetcher_deletes_reader'
require 'traject/writers/delete_writer'

settings do
  provide 'solr.url', ENV['SOLR_URL']
  provide 'solr.version', ENV['SOLR_VERSION']
  provide 'processing_thread_pool', ENV['NUM_THREADS']
  provide 'reader_class_name', 'Traject::PurlFetcherDeletesReader'
  provide 'writer_class_name', 'Traject::DeleteWriter'
end

to_field 'id' do |record, accumulator|
  accumulator << record.strip
end