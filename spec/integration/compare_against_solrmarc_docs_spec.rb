require 'spec_helper'

describe 'comparing against a well-known location full of documents generated by solrmarc' do
  subject(:result) { indexer.map_record(record) }

  let(:indexer) do
    Traject::Indexer.new.tap do |i|
      i.load_config_file('./lib/traject/config/sirsi_config.rb')
    end
  end

  let(:record) { MARC::XMLReader.new(StringIO.new(marcxml)).to_a.first }
  let(:ignored_fields) { %w[created last_updated format] }
  let(:pending_fields) { %w[reverse_shelfkey shelfkey preferred_barcode item_display] }
  subject(:result) { indexer.map_record(record).transform_values { |v| v.sort } }

  Dir.glob(File.expand_path('solrmarc_example_docs/*', file_fixture_path)).each do |fixture|
    context "with #{fixture}" do
      let(:file) { File.read(fixture) }
      let(:data) { JSON.parse(file) }
      let(:solrmarc_doc) { data['doc'] }
      let(:expected_doc) do
        data['doc'].transform_values { |v| Array(v).map(&:to_s).sort }
      end
      let(:marcxml) { solrmarc_doc['marcxml'] }

      it 'maps the same general output' do
        pending if fixture =~ /7046041/
        expect(result).to include expected_doc.reject { |k, v| (ignored_fields + pending_fields).include? k }
      end

      it 'maps the same general output' do
        skip unless pending_fields.any?
        pending
        expect(result.select { |k, v| pending_fields.include? k}).to include expected_doc.select { |k, v| pending_fields.include? k }
      end
    end
  end

  $start = 0
  $rows = 500

  until $start >= ENV.fetch('limit', '100000').to_i
    context "with docs (start: #{$start}, seed: #{RSpec.configuration.seed})", start: $start do

      it 'maps the same general output' do |example|
        # If you populate an index with all stored fields, this can be used to compare
        # the resulting output against the output from traject.

        skip unless ENV['SOLRMARC_STORED_FIELDS_SOLR_BASE_URL']
        url = "#{ENV['SOLRMARC_STORED_FIELDS_SOLR_BASE_URL']}/select?q=#{ENV.fetch('q', '*:*')}&fl=*&rows=#{$rows}&start=#{example.metadata[:start]}&sort=random#{RSpec.configuration.seed}+asc"
        response =  HTTP.get(url)
        docs = JSON.parse(response)['response']['docs']
        aggregate_failures do
          docs.each do |doc|
            print '.'
            record = MARC::XMLReader.new(StringIO.new(doc['marcxml'])).to_a.first
            actual = indexer.map_record(record).transform_values { |v| Array(v).map(&:to_s).sort }
            expected = doc.transform_values { |v| Array(v).map(&:to_s).sort }

            expect(actual).to include expected.reject { |k, v| (ignored_fields + pending_fields).include? k }
          end
        end
      end
    end
    $start += $rows
  end
end
