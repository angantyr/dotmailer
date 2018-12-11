require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'
require 'time'

module DotMailer
  class AddressBook
    def self.find_by_id(account, id)
      response = account.client.get("/address-books/#{id}")
      new(account, response)
    rescue DotMailer::NotFound
      nil
    end

    def initialize(account, attributes)
      self.account    = account
      self.attributes = attributes
    end

    def id
      attributes['id']
    end

    def name
      attributes['name']
    end

    # TODO: check private || public
    def visibility
      attributes['visibility']
    end

    # FIXME: rename method to contacts_count?
    # this method should return a list of contact objects
    def contacts
      attributes['contacts']
    end

    def to_s
      %{#{self.class.name} id: #{id}, name: #{name}, visibility: #{visibility}, contacts: #{contacts} }
    end

    def inspect
      to_s
    end

    def save
      client.put_json "/address-books/#{id}", attributes
    end

    def delete
      client.delete "/address-books/#{id}"
    end

    def add_contact(contact)
      client.post_json "/address-books/#{id}/contacts", contact.to_json
    end

    private
    attr_accessor :attributes, :account

    def client
      account.client
    end

  end
end
