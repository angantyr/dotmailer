module DotMailer
  class ConsentFields
    def initialize(text, request)
      @text = text || 'send me more stuff'
      @consented_at = Time.now
      @url = request.url
      @ip_address = request.remote_ip
      @user_agent = request.user_agent
    end

    def to_s
      %{#{self.class.name} text: #{text}, consented_at: #{consented_at}, url: #{url}, ip_address: #{ip_address}, user_agent: #{user_agent}}
    end

    def inspect
      to_s
    end

    def to_json
      [
        fields: [
          {
            "key": "TEXT",
            "value": text
          },
          {
            "key": "DATETIMECONSENTED",
            "value": consented_at.utc.xmlschema
          },
          {
            "key": "URL",
            "value": url
          },
          {
            "key": "IPADDRESS",
            "value": ip_address
          },
          {
            "key": "USERAGENT",
            "value": user_agent
          }
        ]
      ]
    end


    attr_accessor :text, :consented_at, :url, :ip_address, :user_agent
    protected
  end
end
