require 'dot_mailer/exceptions'
require 'dot_mailer/data_field'
require 'dot_mailer/contact_import'
require 'dot_mailer/contact'
require 'dot_mailer/address_book'
require 'dot_mailer/suppression'
require 'dot_mailer/from_address'
require 'dot_mailer/campaign'
require 'dot_mailer/account'
require 'dot_mailer/client'
require 'dot_mailer/segment'
require 'dot_mailer/campaign_summary'

module DotMailer
  SUBSCRIBED_STATUS          = 'Subscribed'
  GLOBALLY_SUPPRESSED_STATUS = 'Globally Suppressed'
end
