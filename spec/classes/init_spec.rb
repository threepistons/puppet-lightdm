require 'spec_helper'
describe 'lightdm' do

  context 'on unsupported distributions' do
    let(:facts) {{ :osfamily => 'Unsupported' }}

    it 'it fails' do
      expect { subject.call }.to raise_error(/is not supported on an Unsupported based system/)
    end
  end

  ['Debian'].each do |distro|
    context "on #{distro} with default settings" do
      let(:facts) {{
        :osfamily => distro,
        :lsbdistid => distro,
        :lsbdistcodename => 'jessie',
      }}

      it { should contain_class('lightdm::install') }
      it { should contain_class('lightdm::config') }
      it { should contain_class('lightdm::service') }

      describe 'package installation' do
        it { should contain_package('lightdm').with(
          'ensure' => 'installed',
          'name'   => 'lightdm',
          'before' => 'File[default-display-manager]',
          'notify' => 'Exec[set shared/default-x-display-manager]'
        )}
      end

      describe 'not generate lightdm.conf' do
        it { should_not contain_file('lightdm.conf') }
      end

      describe 'not generate users.conf' do
        it { should_not contain_file('users.conf') }
      end

      describe 'generate default-display-manager' do
        it { should contain_file('default-display-manager').with(
          'ensure' => 'file',
          'path' => '/etc/X11/default-display-manager'
        )}
        it 'should set lightdm as default display manager' do
          should contain_file('default-display-manager') \
            .with_content("/usr/sbin/lightdm\n")
        end
      end

      describe 'set shared/default-x-display-manager in debconf' do
        it { should contain_exec('set shared/default-x-display-manager').with(
          'command' => 'echo lightdm shared/default-x-display-manager select lightdm | debconf-set-selections',
          'require' => 'Package[lightdm]'
        )}
      end

      describe 'run dpkg-reconfigure lightdm' do
        it { should contain_exec('dpkg-reconfigure lightdm').with(
          'command' => 'dpkg-reconfigure lightdm',
        )}
      end

      describe 'stop display-manager service' do
        it { should contain_exec('stop other display-manager').with(
          'command' => 'systemctl stop display-manager',
        )}
      end

      describe 'start display-manager service' do
        it { should contain_service('display-manager').with(
          'ensure' => 'running',
        )}
      end
    end

    context "on #{distro}" do
      let(:facts) {{
        :osfamily => distro,
        :lsbdistid => distro,
        :lsbdistcodename => 'jessie',
      }}

      let(:params) {{
        :config => {
          'Seat:*' => {
            'autologin-user' => 'ubuntu',
          }
        },
        :config_users => {
          'UserList' => {
            'minimum-uid' => '500',
            'hidden-users' => 'nobody nobody4 noaccess',
            'hidden-shells' => '/bin/false /usr/sbin/nologin',
          }
        }
      }}

      it { should contain_class('lightdm::install') }
      it { should contain_class('lightdm::config') }
      it { should contain_class('lightdm::service') }

      describe 'package installation' do
        it { should contain_package('lightdm').with(
          'ensure' => 'installed',
          'name'   => 'lightdm'
        )}
      end

      describe 'configure lightdm.conf' do
        it { should contain_file('lightdm.conf').with(
          'ensure' => 'file',
          'path'   => '/etc/lightdm/lightdm.conf',
          'notify' => 'Class[Lightdm::Service]'
        )}
        it 'should set supplied options' do
          should contain_file('lightdm.conf') \
            .with_content(/\[Seat:\*\]/) \
            .with_content(/autologin-user=ubuntu/)
        end
      end

      describe 'configure users.conf' do
        it { should contain_file('users.conf').with(
          'ensure' => 'file',
          'path'   => '/etc/lightdm/users.conf',
          'notify' => 'Class[Lightdm::Service]'
        )}
        it 'should configure supplied options' do
          should contain_file('users.conf') \
            .with_content(/\[UserList\]/) \
            .with_content(/minimum-uid=500/) \
            .with_content(/hidden-users=nobody nobody4 noaccess/) \
            .with_content(%r{hidden-shells=/bin/false /usr/sbin/nologin})
        end
      end
    end

    context "on #{distro}" do
      let(:facts) {{
        :osfamily => distro,
        :lsbdistid => distro,
        :lsbdistcodename => 'jessie',
      }}

      let(:params) {{
        :make_default => false,
      }}

      it { should contain_class('lightdm::install') }
      it { should contain_class('lightdm::config') }
      it { should contain_class('lightdm::service') }

      describe 'package installation' do
        it { should contain_package('lightdm').with(
          'ensure' => 'installed',
          'name'   => 'lightdm'
        )}
      end

      describe 'will not generate default-display-manager' do
        it { should_not contain_file('default-display-manager') }
      end

      describe 'will not set shared/default-x-display-manager in debconf' do
        it { should_not contain_exec('set shared/default-x-display-manager') }
      end

      describe 'will not run dpkg-reconfigure lightdm' do
        it { should_not contain_exec('dpkg-reconfigure lightdm') }
      end

      describe 'will not stop display-manager service' do
        it { should_not contain_exec('stop other display-manager') }
      end

      describe 'start display-manager service' do
        it { should contain_service('display-manager').with(
          'ensure' => 'running',
        )}
      end
    end

    context "on #{distro}" do
      let(:facts) {{
        :osfamily => distro,
        :lsbdistid => distro,
        :lsbdistcodename => 'jessie',
      }}

      let(:params) {{
        :service_manage => false,
      }}

      it { should contain_class('lightdm::install') }
      it { should contain_class('lightdm::config') }
      it { should contain_class('lightdm::service') }

      describe 'will not contain display-manager service' do
        it { should_not contain_service('display-manager') }
      end
    end
  end

end
