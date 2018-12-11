require 'spec_helper'

describe DotMailer::ConsentFields do
  subject {DotMailer::ConsentFields}
  let(:consent_fields) {double 'consent_fields'}
  let(:text)    { 'some consent text' }
  let(:request) { OpenStruct.new( url: 'url', remote_ip: 'ip', user_agent: 'agent' )}
  let(:json) {
    [ fields:
      [
        { "key": "TEXT", "value": 'text' },
        { "key": "DATETIMECONSENTED", "value": 'date' },
        { "key": "URL", "value": 'url' },
        { "key": "IPADDRESS", "value": 'ip' },
        { "key": "USERAGENT", "value": 'agent' }
      ]
    ]
  }

  describe '#initialize' do
    it 'should initialize a ConsentFields object with the text' do
      subject.should_receive(:new).with(text, request)
      DotMailer::ConsentFields.new(text, request)
    end
    it 'should return the new ConsentFields object' do
      subject.stub :new => consent_fields
      DotMailer::ConsentFields.new(text, request).should == consent_fields
    end
  end

  describe '#ip_address' do
    it 'should return Contact in with correct ip' do
      DotMailer::ConsentFields.new(text, request).ip_address == request.remote_ip
    end
  end

  describe '#to_json' do
    it 'should return four required key values'
    it 'should return date value in json xml format'
  end

end
