require 'active_support'
require 'active_support/core_ext/string/inflections'  # For #model_class constantize
require 'active_support/core_ext/array/access'
require 'active_support/core_ext/object/try'          # For #find
require 'uri'

class GlobalID
  class << self
    attr_accessor :app

    def create(model)
      new URI("gid://#{GlobalID.app}/#{model.class.name}/#{model.id}")
    end

    def find(gid)
      parse(gid).try :find
    end

    def parse(gid)
      gid.is_a?(self) ? gid : new(gid)
    rescue URI::Error
      parse_encoded_gid(gid)
    end

    def parse_encoded_gid(gid)
      padding_chars = 4 - gid.length % 4
      gid += '=' * padding_chars
      new(Base64.urlsafe_decode64(gid)) rescue nil
    end
  end

  attr_reader :uri, :app, :model_name, :model_id

  def initialize(gid)
    extract_uri_components gid
  end

  def find
    model_class.find model_id
  end

  def model_class
    model_name.constantize
  end

  def ==(other)
    other.is_a?(GlobalID) && @uri == other.uri
  end

  def to_s
    @uri.to_s
  end

  def to_param
    Base64.urlsafe_encode64(to_s).sub(/=+$/, '')
  end

  private
    PATH_REGEXP = %r(\A/([^/]+)/([^/]+)\z)

    # Pending a URI::GID to handle validation
    def extract_uri_components(gid)
      @uri = gid.is_a?(URI) ? gid : URI.parse(gid)
      raise URI::BadURIError, "Not a gid:// URI scheme: #{@uri.inspect}" unless @uri.scheme == 'gid'

      if @uri.path =~ PATH_REGEXP
        @app = @uri.host
        @model_name = $1
        @model_id = $2
      else
        raise URI::InvalidURIError, "Expected a URI like gid://app/Person/1234: #{@uri.inspect}"
      end
    end
end
