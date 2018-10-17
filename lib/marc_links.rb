module MarcLinks
  PROXY_REGEX = /stanford\.idm\.oclc\.org/

  class Processor
    attr_reader :link_field

    def initialize(link_field)
      @link_field = link_field
    end
    def as_h
      link = process_link(link_field)
      if link
        {
          html: ["<a title='#{link[:title]}' href='#{link[:href]}'>#{link[:text]}</a>", "#{'(source: Casalini)' if link[:casalini_toc]}", (" #{link[:additional_text]}" if link[:additional_text])].compact.join(' '),
          text: [link[:text], "#{'(source: Casalini)' if link[:casalini_toc]}", " #{link[:additional_text] if link[:additional_text]}"].compact.join(' ').strip,
          href: link[:href],
          fulltext: link_is_fulltext?(link_field),
          stanford_only: stanford_only?(link),
          finding_aid: link_is_finding_aid?(link_field),
          managed_purl: link_is_managed_purl?(link),
          file_id: file_id(link_field),
          druid: druid(link)
        }
      end
    end

    private

    def file_id(link_field)
      return unless link_field['x']
      subxs = link_field.subfields.select do |subfield|
        subfield.code == 'x'
      end

      file_id_value = subxs.find do |subx|
        subx.value.start_with?('file:')
      end&.value

      file_id_value.gsub('file:', '') if file_id_value
    end

    # Parse a URI object to return the host of the URL in the "url" parameter if it's a proxied resoruce
    def link_host(link)
      return link.host unless link.to_s =~ PROXY_REGEX && link.to_s.include?('url=')
      proxy = CGI.parse(link.query)
      return link.host unless proxy.key?('url')

      extracted_url = URI.extract(proxy['url'].first).first
      return link.host unless extracted_url
      URI.parse(extracted_url).host
    end

    def process_link(field)
      unless field['u'].nil?
        # Not sure why I need this, but it fails on certain URLs w/o it.  The link printed still has character in it
        fixed_url = field['u'].gsub("^","").strip
        url = URI.parse(fixed_url)
        sub3 = nil
        subz = []
        suby = nil
        field.each{|subfield|
          if subfield.code == "3"
            sub3 = subfield.value
          elsif subfield.code == "z"
            subz << subfield.value
          elsif subfield.code == "y"
            suby = subfield.value
          end
        }

        if field["x"] and field["x"] == "CasaliniTOC"
          {:text=>field["3"],
           :title=>"",
           :href=>field["u"],
           :casalini_toc => true,
           :managed_purl => (field["u"] && field['x'] =~ /SDR-PURL/)
          }
        else
          link_text = (!suby && !sub3) ? link_host(url) : [sub3, suby].compact.join(' ')
          title = subz.join(" ")
          additional_text = nil
          if title =~ stanford_affiliated_regex
            additional_text = "<span class='additional-link-text'>#{title.gsub(stanford_affiliated_regex, '')}</span>"
            title = "Available to Stanford-affiliated users only"
          end
          {:text=>link_text,
           :title=> title,
           :href=>field["u"],
           :casalini_toc => false,
           :additional_text => additional_text,
           :managed_purl => (field["u"] && field['x'] =~ /SDR-PURL/)
          }
        end
      end
      rescue URI::InvalidURIError
        return nil
    end
    def link_is_fulltext?(field)
      resource_labels = ["table of contents", "abstract", "description", "sample text"]
      if field.indicator2 == "2"
        return false
      elsif field.indicator2 == "0" or field.indicator2 == "1" or field.indicator2.nil? or field.indicator2.empty?
        resource_labels.each do |resource_label|
          return false if "#{field['3']} #{field['z']}".downcase.include?(resource_label)
        end
        return true
      else
        # this should catch bad indicators
        return nil
      end
    end

    def link_is_finding_aid?(field)
      "#{field['3']} #{field['z']}".downcase.include?('finding aid')
    end

    def stanford_only?(link)
      [link[:text], link[:title]].join.downcase =~ stanford_affiliated_regex
    end

    def link_is_managed_purl?(link)
      link[:managed_purl]
    end

    def druid(link)
      link[:href].gsub(%r{^https?:\/\/purl.stanford.edu\/?}, '') if link[:href] =~ /purl.stanford.edu/
    end

    def stanford_affiliated_regex
      Regexp.new(/available[ -]?to[ -]?stanford[ -]?affiliated[ -]?users[ -]?a?t?[:;.]?/i)
    end
  end
end
