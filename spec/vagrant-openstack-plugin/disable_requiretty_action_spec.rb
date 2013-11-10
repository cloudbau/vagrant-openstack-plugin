require 'spec_helper'

describe VagrantPlugins::OpenStack::Action::DisableRequiretty do
  subject { described_class.new app, env }
  let(:app) { double 'app' }
  let(:env) do
    {
      machine: OpenStruct.new({
        provider_config: OpenStruct.new(disable_requiretty: disable_requiretty)
      })
    }
  end

  let(:helper) { VagrantPlugins::OpenStack::Helper::Machine.any_instance }
  let(:provider_config) { double 'provider_config' }

  describe '#call' do
    subject { described_class.new(app, env).call env }

    context 'when disable_requiretty is true' do
      let(:disable_requiretty) { true }

      it 'should disable sudo requiretty' do
        helper.should_receive(:disable_requiretty)
        expect(app).to receive(:call).with env
        subject
      end
    end

    context 'when disable_requiretty is nil' do
      let(:disable_requiretty) { nil }

      it 'should disable sudo requiretty' do
        helper.should_receive(:disable_requiretty)
        expect(app).to receive(:call).with env
        subject
      end
    end


    context 'when disable_requiretty is false' do
      let(:disable_requiretty) { false }

      it 'should not disable sudo requiretty' do
        helper.should_not_receive(:disable_requiretty)
        expect(app).to receive(:call).with env
        subject
      end
    end
  end
end
