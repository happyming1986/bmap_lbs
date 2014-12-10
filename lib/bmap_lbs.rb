require "bmap_lbs/version"

module BmapLbs
  module Configure
    cattr_accessor :ak, :sn, :geotable_id, :coord_type, instance_writer: false, instance_reader: false
  end

  def self.setup(&block)
    self::Configure.instance_eval(&block)
  end

  class << self
    def create(hash)
      params = hash.merge(base_configure)
      url =  URI("http://api.map.baidu.com/geodata/v3/poi/create")
      res = Net::HTTP.post_form(url, params)
      Rails.logger.info res.body
      return JSON.parse(res.body)['status'] == 0
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
  end
end
