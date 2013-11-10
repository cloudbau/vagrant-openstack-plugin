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
    let('user') { 'randomusername' }
    let('ssh_user') { 'ssh_user' }

    its(:machine) { should == machine }

    describe '#add_user' do
      subject { described_class.new(machine).add_user user }

      it 'should add a user' do
        expect(ssh).to receive(:username).and_return ssh_user
        expect(ssh).to receive(:username=).with 'root'
        expect(communicate).to receive(:execute) do |command|
          expect(command).to be_shell_command %Q(
            if ! (grep #{user} /etc/passwd); then
              useradd -m -s /bin/bash #{user};
            fi)
        end
        expect(ssh).to receive(:username=).with ssh_user
        subject
      end
    end

    describe '#setup_sudo' do
      subject { described_class.new(machine).setup_sudo user }

      it 'should setup sudo' do
        expect(ssh).to receive(:username).and_return ssh_user
        expect(ssh).to receive(:username=).with 'root'
        expect(communicate).to receive(:execute) do |command|
          expect(command).to be_shell_command %Q(
            if ! (grep #{user} /etc/sudoers); then
              echo "#{user} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers;
            fi
          )
        end
        expect(ssh).to receive(:username=).with ssh_user
        subject
      end
    end

    describe '#create_ssh_dir' do
      subject { described_class.new(machine).create_ssh_dir user }

      it 'should create ssh dir' do
        expect(ssh).to receive(:username).and_return ssh_user
        expect(ssh).to receive(:username=).with 'root'
        expect(communicate).to receive(:execute) do |command|
          expect(command).to be_shell_command "su #{user} -c 'mkdir -p ~/.ssh'"
        end
        expect(ssh).to receive(:username=).with ssh_user
        subject
      end
    end

    describe '#copy_authorized_keys' do
      subject { described_class.new(machine).copy_authorized_keys user }
      let('user') { 'randomusername' }
      let('key') { 'randomkey' }

      it 'should copy root\'s authorized keys' do
        expect(ssh).to receive(:username).and_return ssh_user
        expect(ssh).to receive(:username=).with 'root'
        expect(communicate).to receive(:execute) do |command|
          expect(command).to be_shell_command %Q(
            cp ~/.ssh/authorized_keys /home/#{user}/.ssh
            chown #{user} /home/#{user}/.ssh/authorized_keys
          )
        end
        expect(ssh).to receive(:username=).with ssh_user
        subject
      end
    end

    describe '#disable_sudo_requiretty' do
      subject { described_class.new(machine).disable_sudo_requiretty }

      it 'should disable requiretty in /etc/sudoers' do
        expect(ssh).to receive(:username).and_return ssh_user
        expect(ssh).to receive(:username=).with 'root'
        expect(communicate).to receive(:execute) do |command|
          expect(command).to be_shell_command %q(
            sed -i'.bk' -e 's/^\\\(Defaults\s\+requiretty\\\)/# \1/' /etc/sudoers
          )
        end
        expect(ssh).to receive(:username=).with ssh_user
        subject
      end
    end
  end
end
