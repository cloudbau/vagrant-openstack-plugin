require 'spec_helper'

describe VagrantPlugins::OpenStack::Helper::Machine do
  subject { described_class.new machine }

  context 'given a valid machine' do
    let(:machine) do
      OpenStruct.new({
        communicate: communicate,
        config: OpenStruct.new(ssh: ssh)

      })
    end
    let(:communicate) { double 'communicate' }
    let(:ssh) { double 'ssh' }
    let('ssh_user') { 'ssh_user' }

    its(:machine) { should == machine }

    describe '#disable_requiretty' do
      subject { described_class.new(machine).disable_requiretty }

      it 'should disable requiretty in /etc/sudoers' do
        expect(communicate).to receive(:execute) do |command|
          expect(command).to be_shell_command %q(
            sed -i'.bk' -e 's/^\\\(Defaults\s\+requiretty\\\)/# \1/' /etc/sudoers
          )
        end
        subject
      end
    end
  end
end
