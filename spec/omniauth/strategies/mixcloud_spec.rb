require 'spec_helper'
require 'omniauth-mixcloud'

describe OmniAuth::Strategies::MixCloud do
  let(:request) do
    double('request',
            :params => {},
            :cookies => {},
            :env => {})
  end

  subject do
    OmniAuth::Strategies::MixCloud.new(nil, @options || {}).tap do |strategy|
      strategy.stub(:request => request)
    end
  end

  it_should_behave_like 'an oauth2 strategy'

  describe '#client' do
    it 'should have the correct MixCloud site' do
      subject.client.site.should eq("https://api.mixcloud.com")
    end

    it 'should have the correct authorization url' do
      subject.client.options[:authorize_url].should eq("/oauth/authorize")
    end

    it 'should have the correct token url' do
      subject.client.options[:token_url].should eq('/oauth/access_token')
    end
  end

  describe '#callback_path' do
    it 'should have the correct callback path' do
      subject.callback_path.should eq('/auth/mixcloud/callback')
    end
  end

   describe '#authorize_params' do
    it 'includes display parameter from request when present' do
      request.stub(:params) { { 'display' => 'touch' } }
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:display].should eq('touch')
    end

    it 'includes state parameter from request when present' do
      request.stub(:params) { { 'state' => 'some_state' } }
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:state].should eq('some_state')
    end

    it 'overrides default scope with parameter passed from request' do
      request.stub(:params) { { 'scope' => 'email' } }
      subject.authorize_params.should be_a(Hash)
      subject.authorize_params[:scope].should eq('email')
    end
   end
end
