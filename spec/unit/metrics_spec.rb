require 'spec_helper'

module AppOptics

  describe Metrics do

   describe "#authorize" do
     context "when given two arguments" do
       it "stores them on simple" do
         Metrics.authenticate 'api_key'
         expect(Metrics.client.api_key).to eq('api_key')
       end
     end
   end

   describe "#faraday_adapter" do
     it "returns current default adapter" do
       expect(Metrics.faraday_adapter).not_to be_nil
     end
   end

   describe "#faraday_adapter=" do
     before(:all) { @current_adapter = Metrics.faraday_adapter }
     after(:all) { Metrics.faraday_adapter = @current_adapter }

     it "allows setting of faraday adapter" do
       Metrics.faraday_adapter = :excon
       expect(Metrics.faraday_adapter).to eq(:excon)
       Metrics.faraday_adapter = :patron
       expect(Metrics.faraday_adapter).to eq(:patron)
     end
   end

   describe "#persistence" do
     it "allows configuration of persistence method" do
       Metrics.persistence = :test
       expect(Metrics.persistence).to eq(:test)
     end
   end

   describe "#submit" do
     before(:all) do
       AppOptics::Metrics.persistence = :test
       AppOptics::Metrics.authenticate 'me@AppOptics.com', 'foo'
     end
     after(:all) { AppOptics::Metrics.client.flush_authentication }

     it "persists metrics immediately" do
       Metrics.persistence = :test
       expect(Metrics.submit(foo: 123)).to be true
       expect(Metrics.persister.persisted).to eq({gauges: [{name: 'foo', value: 123}]})
     end

     it "tolerates multiple metrics" do
       expect { AppOptics::Metrics.submit foo: 123, bar: 456 }.not_to raise_error
       expected = {gauges: [{name: 'foo', value: 123}, {name: 'bar', value: 456}]}
       expect(AppOptics::Metrics.persister.persisted).to equal_unordered(expected)
     end
   end

  end

end
