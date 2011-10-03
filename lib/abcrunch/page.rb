module AbCrunch
  module Page
    def self.get_url(page, force_new = false)
      if force_new || !page[:testing_url]
        url = page[:url]
        if url.respond_to? :call
          url = url.call
        end
        page[:testing_url] = url
      else
        url = page[:testing_url]
      end

      url
    end
  end
end