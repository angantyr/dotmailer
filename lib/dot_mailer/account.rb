require 'active_support/core_ext/numeric/time'
require 'active_support/cache'

module DotMailer
  class Account
    CACHE_LIFETIME = 1.minute

    attr_reader :client

    def initialize(api_user, api_pass)
      self.client = Client.new(api_user, api_pass)
    end

    def data_fields
      cache.fetch 'data_fields' do
        DataField.all self
      end
    end

    def create_data_field(name, options = {})
      DataField.create self, name, options

      cache.delete 'data_fields'
    end

    def import_contacts(contacts, options = {})
      ContactImport.import self, contacts, options[:wait_for_finish]
    end

    def find_contact_by_email(email)
      Contact.find_by_email self, email
    end

    def find_contact_by_id(id)
      Contact.find_by_id self, id
    end

    def find_contacts_modified_since(time)
      Contact.modified_since(self, time)
    end

    def find_address_book_by_id(id)
      AddressBook.find_by_id self, id
    end

    def find_suppressions_since(time)
      Suppression.suppressed_since(self, time)
    end

    def suppress(email)
      client.post_json '/contacts/unsubscribe', 'Email' => email
    end

    def from_addresses
      response = cache.fetch 'from_addresses' do
        client.get('/custom-from-addresses')
      end

      response.map { |a| FromAddress.new(a) }
    end

    def create_campaign(attributes)
      Campaign.create(self, attributes)
    end

    def find_campaign_by_id(id)
      Campaign.find_by_id(self, id)
    end

    def find_segment_by_id(id)
      DotMailer::Segment.find_by_id(self, id)
    end

    def to_s
      "#{self.class.name} client: #{client}"
    end

    def inspect
      to_s
    end

    private
    attr_writer :client

    def cache
      # Auto expire content after CACHE_LIFETIME seconds
      @cache ||= ActiveSupport::Cache::MemoryStore.new :expires_in => CACHE_LIFETIME
    end
  end
end
