require 'open-uri'
require 'ostruct'

module TwitterOAuth
  class Client

    def search(q, options={})
      options[:page] ||= 1
      options[:per_page] ||= 20
      response = open("http://search.twitter.com/search.json?q=#{URI.escape(q)}&page=#{options[:page]}&rpp=#{options[:per_page]}&since_id=#{options[:since_id]}")
      search_result = JSON.parse(response.read)
      search_result = OpenStruct.new(search_result)

      klass = make_klass(search_result.results.first)

      search_result.results = search_result.results.collect do |res|
        klass.new(res)
      end

      search_result
    end

    private

    # Returns an OpenStruct-esque class that doesn't whine about calling #id
    def make_klass(result)
      keys = result.keys.map(&:to_sym)
      Class.new do
        attr_accessor *keys

        def initialize(hash)
          hash.each { |key,val| send("#{key}=", val) }
        end

        def method_missing(*args)
          nil
        end
      end
    end

  end
end
