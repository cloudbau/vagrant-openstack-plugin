require 'spec_helper'

describe VagrantPlugins::OpenStack::Action::SetupUser do
  subject { described_class.new app, env }
  let(:app) { double 'app' }
  let(:env) do
    {
      machine: OpenStruct.new({
        config: OpenStruct.new({
          ssh: OpenStruct.new(username: provided_user)
        }),
        communicate: communicate,
        ssh_info: ssh_info
      }),
      ui: ui,
    }
  end

  let(:communicate) { double 'communicate' }
  let(:ui) { double 'ui' }
  let(:ssh_info) { double 'ssh_info' }
  let(:helper) { VagrantPlugins::OpenStack::Helper::Machine.any_instance }

  describe '#call' do
    subject { described_class.new(app, env).call env }

    before do
      allow(ui).to receive :info
      expect(app).to receive :call
    end

    context 'given an explicit user' do
      let(:provided_user) { 'someuser' }

      it 'should setup the provided user' do
        helper.should_receive(:add_user).with(provided_user)
        helper.should_receive(:setup_sudo).with(provided_user)
        helper.should_receive(:create_ssh_dir).with(provided_user)
        helper.should_receive(:copy_authorized_keys).with(provided_user)
        helper.should_receive(:disable_sudo_requiretty)
        ssh_info.should_receive(:[]=).with :username, provided_user
        subject
      end
    end

    context 'given no user' do
      let(:provided_user) { 'vagrant' }
      it 'should setup a user named \'vagrant\'' do
        helper.should_receive(:add_user).with(provided_user)
        helper.should_receive(:setup_sudo).with(provided_user)
        helper.should_receive(:create_ssh_dir).with(provided_user)
        helper.should_receive(:copy_authorized_keys).with(provided_user)
        helper.should_receive(:disable_sudo_requiretty)
        ssh_info.should_receive(:[]=).with :username, provided_user
        subject
      end
    end


    context 'given root as the ssh user' do
      let(:provided_user) { 'root' }

      it 'not try to create root' do
        helper.should_not_receive(:add_user)
        helper.should_not_receive(:setup_sudo)
        helper.should_not_receive(:create_ssh_dir)
        helper.should_not_receive(:copy_authorized_keys)
        helper.should_receive(:disable_sudo_requiretty)
        ssh_info.should_receive(:[]=).with :username, provided_user
        subject
      end
    end
  end
end

