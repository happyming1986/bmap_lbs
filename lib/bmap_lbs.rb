require "bmap_lbs/version"
module BmapLbs
  module Configure
    cattr_accessor :ak, :sn, :geotable_id, :coord_type, :exception_handle, instance_writer: false, instance_reader: false
  end

  class BmapLbsCommunicateFailure < StandardError
  end

  def self.setup(&block)
    self::Configure.instance_eval(&block)
  end

  class << self

    #get table details
    def table_details(hash={})
      params = hash.merge(base_configure).symbolize_keys
      check_value_exist(params, [:ak, :geotable_id])
      params = params.transform_keys { |key| key == :geotable_id ? 'id':key}
      @res = send_request(:get, "http://api.map.baidu.com/geodata/v3/geotable/detail", params)
    end

    # show all column details in a geotable
    def columns_details(hash={})
      params = hash.merge(base_configure)
      check_value_exist(params, [:ak, :geotable_id])
      @res = send_request(:get, "http://api.map.baidu.com/geodata/v3/column/list", params)
      return @res[:columns]
    end

    # show a geotable column details
    def column_details(hash)
      params = hash.merge(base_configure)
      check_value_exist(params, [:ak, :geotable_id, :id])
      @res = send_request(:get, "http://api.map.baidu.com/geodata/v3/column/detail", params)
      return @res[:column]
    end

    #update column attribute
    def update_column(hash)
      params = hash.merge(base_configure)
      check_value_exist(params, [:ak, :geotable_id, :id])
      @res = send_request(:post, "http://api.map.baidu.com/geodata/v3/column/update", params)
      return @res[:status].to_i.eql? 0
    end

    #list poi on some conditions
    def list_pois(hash={})
      params = hash.merge(base_configure)
      check_value_exist(params, [:ak, :geotable_id])
      @res = send_request(:get, "http://api.map.baidu.com/geodata/v3/poi/list", params)
      return @res[:pois]
    end

    #operate poi,with ! will raise error if faild
    [:delete, :create, :update].each do |i|
      define_method("#{i}_poi") do |hash|
        params = hash.merge(base_configure)
        check_value_exist(params, [:ak, :geotable_id])
        @res = send_request(:post, "http://api.map.baidu.com/geodata/v3/poi/#{i}", params)
        return @res[:status].to_i.eql? 0
      end

      define_method("#{i}_poi!") do |hash|
        result = send("#{i}_poi", hash)
        unless result
          raise BmapLbsCommunicateFailure, "#{@res[:status]};#{@res[:message]}"
        end
        true
      end
    end

    private

    def base_configure
      block = -> do
        hash = {}
        [:ak, :sn, :geotable_id].each do |i|
          hash[i] = Configure.send(i) if Configure.send(i).present?
        end
        return hash
      end
      return @base_configure ||= block.call
    end

    def check_value_exist(hash, array)
      if hash.symbolize_keys.values_at(*array.map(&:to_sym)).include?(nil)
        raise ArgumentError, 'lack of important key.'
      end
    end

    def send_request(type, url, params)
      begin
        case type.to_sym
          when :post
            url =  URI(url)
            res = Net::HTTP.post_form(url, params)
          when :get
            url = URI(url+'?'+params.to_query)
            res = Net::HTTP.get_response(url)
        end
        hash = JSON.parse(res.body)
        Rails.logger.info hash.inspect
      rescue Exception => e
        if Configure.exception_handle.present?
          e.instance_eval(&Configure.exception_handle)
        else
          railse e
        end
      end
      return hash.with_indifferent_access
    end

  end

end
