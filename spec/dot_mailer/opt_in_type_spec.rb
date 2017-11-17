require 'spec_helper'

describe DotMailer::OptInType do
  describe 'Class' do
    subject { DotMailer::OptInType }

    describe '.exists?' do
      context 'when the opt in type exists' do
        let(:opt_in_type) { DotMailer::OptInType::SINGLE }

        specify { subject.exists?(opt_in_type).should be true }
      end

      context 'when the opt in type doesnt exist' do
        let(:opt_in_type) { 'Something Random' }

        specify { subject.exists?(opt_in_type).should be false }
      end
    end
  end
end
