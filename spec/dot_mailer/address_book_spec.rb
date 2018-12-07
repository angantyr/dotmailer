require 'spec_helper'

describe DotMailer::AddressBook do
  let(:client)  { double 'client' }
  let(:account) { double 'account', :client => client }

  describe 'Class' do
    subject { DotMailer::AddressBook }

    describe '.find_by_id' do
      let(:id)        { '123' }
      let(:response)  { double 'response' }
      let(:address_book)   { double 'address_book' }

      before(:each) do
        client.stub :get => response
        subject.stub :new => address_book
      end

      it 'should get the address book from the client' do
        client.should_receive(:get).with("/address-books/#{id}")
        subject.find_by_id account, id
      end

      it 'should initialize a new Address Book with the response from the client' do
        subject.should_receive(:new).with(account, response)
        subject.find_by_id account, id
      end

      it 'should return the new Address Book object' do
        subject.find_by_id(account, id).should == address_book
      end

      context 'when the address book doesnt exist' do
        before(:each) do
          client.stub(:get).and_raise(DotMailer::NotFound)
        end

        it 'should return nil' do
          subject.find_by_id(account, id).should be_nil
        end
      end
    end

  end

end
