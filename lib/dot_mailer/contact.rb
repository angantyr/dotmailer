require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'
require 'time'

require 'dot_mailer/opt_in_type'

module DotMailer
  class Contact

    def self.create(account, attributes, data_fields={})
      params = {}
      params['email']         = attributes[:email]          || raise('missing :email')
      params['optInType']     = attributes[:opt_in_type]    || raise('missing :opt_in_type')
      params['emailType']     = attributes[:email_type]     || raise('missing :email_type')
      params['dataFields']    = data_fields if data_fields

      response = account.client.post_json('/contacts', params)

      new(account, response)
    end

    def self.create_with_consent(account, attributes, data_fields, consent_fields)
      params = {}
      params['contact'] = {}
      params['contact']['email']         = attributes[:email]          || raise('missing :email')
      params['contact']['optInType']     = attributes[:opt_in_type]    || raise('missing :opt_in_type')
      params['contact']['emailType']     = attributes[:email_type]     || raise('missing :email_type')
      params['contact']['dataFields']    = data_fields if data_fields

      params['consentFields'] = consent_fields
      response = account.client.post_json('/contacts/with-consent', params)
      # NOTE: .create_with_consent returns a different hash than .create
      # build the contact object from only the contact portion of the hash
      new(account, response['contact'])
    end

    def self.find_by_email(account, email)
      response = account.client.get("/contacts/#{email}")

      new(account, response)
    rescue DotMailer::NotFound
      nil
    end

    # The API makes no distinction between finding
    # by email or id, so we just delegate to
    # Contact.find_by_email
    def self.find_by_id(account, id)
      find_by_email account, id
    end

    def self.modified_since(account, time)
      response = account.client.get("/contacts/modified-since/#{time.utc.xmlschema}")

      response.map do |attributes|
        new(account, attributes)
      end
    end

    def initialize(account, attributes)
      self.account    = account
      self.attributes = attributes
    end

    def id
      attributes['id']
    end

    def email
      attributes['email']
    end

    def email=(email)
      attributes['email'] = email
    end

    def opt_in_type
      attributes['optInType']
    end

    def opt_in_type=(opt_in_type)
      raise UnknownOptInType, opt_in_type unless OptInType.exists?(opt_in_type)

      attributes['optInType'] = opt_in_type
    end

    def email_type
      attributes['emailType']
    end

    def email_type=(email_type)
      attributes['emailType'] = email_type
    end

    def status
      attributes['status']
    end

    def to_s
      %{#{self.class.name} id: #{id}, email: #{email}, opt_in_type: #{opt_in_type}, email_type: #{email_type}, status: #{status}, data_fields: #{data_fields.to_s}}
    end

    def inspect
      to_s
    end

    def to_json
      { 'email': email}
    end


    # A wrapper method for accessing data field values by name, e.g.:
    #
    #   contact['FIRSTNAME']
    #
    def [](key)
      if data_fields.has_key?(key)
        data_fields[key]
      else
        raise UnknownDataField, key
      end
    end

    # A wrapper method for assigning data field values, e.g.:
    #
    #   contact['FIRSTNAME'] = 'Lewis'
    #
    def []=(key, value)
      if data_fields.has_key?(key)
        data_fields[key] = value
      else
        raise UnknownDataField, key
      end
    end

    def update
      client.put_json "/contacts/#{id}", attributes.merge('dataFields' => data_fields_for_api)
    end

    def delete
      client.delete "/contacts/#{id}"
    end

    def subscribed?
      status == SUBSCRIBED_STATUS
    end

    # TODO Should include a address book class
    # https://developer.dotmailer.com/docs/add-contact-to-address-book
    # def subscribe(path = '/contacts')
    #   client.post_json path,
    #     "email" => email,
    #     "optInType" => opt_in_type,
    #     "emailType" => email_type
    # end
    #
    def resubscribe(return_url)
      return false if subscribed?

      client.post_json '/contacts/resubscribe',
        'UnsubscribedContact' => {
          'id'    => id,
          'Email' => email
        },
        'ReturnUrlToUseIfChallenged' => return_url
    end

    private
    attr_accessor :attributes, :account

    def client
      account.client
    end

    # Convert data fields from the API into a flat hash.
    #
    # We coerce Date fields from strings into Time objects.
    #
    # The API returns data field values in the following format:
    #
    #   'dataFields' => [
    #     { 'key' => 'FIELD1', 'value' => 'some value'},
    #     { 'key' => 'FIELD2', 'value' => 'some other value'}
    #   ]
    #
    # We convert that here to:
    #
    #   { 'FIELD1' => 'some value', 'FIELD2' => 'some other value' }
    #
    def data_fields
      # Some API calls (e.g. modified-since) don't return data fields
      return [] unless attributes['dataFields'].present?

      @data_fields ||=
        begin
          account.data_fields.each_with_object({}) do |data_field, hash|
            value = attributes['dataFields'].detect { |f| f['key'] == data_field.name }.try(:[], 'value')

            if value.present? && data_field.date?
              value = Time.parse(value)
            end

            hash[data_field.name] = value
          end
        end
    end

    # Convert data fields from a flat hash to an API compatible hash:
    #
    #   { 'FIELD1' => 'some value', 'FIELD2' => 'some other value' }
    #
    # Becomes:
    #
    #   [
    #     { 'key' => 'FIELD1', 'value' => 'some value'},
    #     { 'key' => 'FIELD2', 'value' => 'some other value'}
    #   ]
    #
    def data_fields_for_api
      data_fields.map do |key, value|
        { 'key' => key, 'value' => value.to_s }
      end
    end
  end
end
