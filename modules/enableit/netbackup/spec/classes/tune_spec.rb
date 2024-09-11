require 'spec_helper'

describe 'netbackup::server::tune' do

  describe 'check defaults' do
    let(:facts) {{:operatingsystem => 'Sles', :operatingsystemrelease => '11.1' }}

    it { should contain_file('/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS') }
    it { should contain_file('/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS') }
    it { should contain_file('/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS_DISK') }
    it { should contain_file('/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS_DISK') }
    it { should contain_file('/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS_FT') }
    it { should contain_file('/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS_FT') }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_NUMBER_DATA_BUFFERS') }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_SIZE_DATA_BUFFERS') }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_WHOLE_IMAGE_COPY').with_ensure('present') }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_UPDATE_INTERVAL') }
    it { should contain_file('/usr/openv/netbackup/db/config/OST_CD_BUSY_RETRY_LIMIT') }
    it { should contain_file('/usr/openv/netbackup/NET_BUFFER_SZ') }
    it { should contain_file('/usr/openv/netbackup/NET_BUFFER_SZ_REST') }
    it { should contain_file('/usr/openv/netbackup/db/config/DPS_PROXYDEFAULTRECVTMO') }
    it { should contain_file('/usr/openv/netbackup/db/config/DPS_PROXYDEFAULTSENDTMO') }
    it { should contain_file('/usr/openv/netbackup/db/config/DPS_PROXYNOEXPIRE') }
    it { should contain_file('/usr/openv/netbackup/db/config/MAX_ENTRIES_PER_ADD') }
    it { should contain_file('/usr/openv/netbackup/db/config/PARENT_DELAY') }
    it { should contain_file('/usr/openv/netbackup/db/config/CHILD_DELAY') }
    it { should contain_file('/usr/openv/netbackup/FBU_READBLKS') }
  end

  describe 'cdwholeimagecopy false' do
    let(:params) { {:cdwholeimagecopy => false} }
    let(:facts) {
      {
        :operatingsystem        => 'Sles',
        :operatingsystemrelease => '11.1'
      }
    }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_WHOLE_IMAGE_COPY').with_ensure('absent') }
  end

  describe 'cdwholeimagecopy true' do
    let(:params) { {:cdwholeimagecopy => true} }
    let(:facts) {
      {
        :operatingsystem        => 'Sles',
        :operatingsystemrelease => '11.1'
      }
    }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_WHOLE_IMAGE_COPY').with_ensure('present') }
  end

  describe 'dpsproxynoexpire false' do
    let(:params) { {:dpsproxynoexpire => false} }
    let(:facts) {
      {
        :operatingsystem        => 'Sles',
        :operatingsystemrelease => '11.1'
      }
    }
    it { should contain_file('/usr/openv/netbackup/db/config/DPS_PROXYNOEXPIRE').with_ensure('absent') }
  end

  describe 'dpsproxynoexpire true' do
    let(:prams) { {:dpsproxynoexpire => false} }
    let(:facts) {
      {
        :operatingsystem        => 'Sles',
        :operatingsystemrelease => '11.1'
      }
    }
  end

  describe 'alter values' do
    let(:facts) {
      {
        :operatingsystem        => 'Sles',
        :operatingsystemrelease => '11.1'
      }
    }
    let(:params) {
      { :sizedatabuffers        => 100,
        :numberdatabuffers      => 100,
        :sizedatabuffersdisk    => 100,
        :numberdatabuffersdisk  => 100,
        :sizedatabuffersft      => 100,
        :numberdatabuffersft    => 100,
        :cdnumberdatabuffers    => 100,
        :cdsizedatabuffers      => 100,
        :cdupdateinterval       => 100,
        :ostcdbusyretrylimit    => 100,
        :netbuffersz            => 100,
        :netbufferszrest        => 100,
        :dpsproxydefaultrecvtmo => 100,
        :dpsproxydefaultsendtmo => 100,
        :maxentriesperadd       => 100,
        :fbureadblks            => '123 456',
      }
    }

    it { should contain_file('/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS_DISK').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS_DISK').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/SIZE_DATA_BUFFERS_FT').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/NUMBER_DATA_BUFFERS_FT').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_NUMBER_DATA_BUFFERS').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_SIZE_DATA_BUFFERS').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/CD_UPDATE_INTERVAL').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/OST_CD_BUSY_RETRY_LIMIT').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/NET_BUFFER_SZ').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/NET_BUFFER_SZ_REST').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/DPS_PROXYDEFAULTRECVTMO').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/DPS_PROXYDEFAULTSENDTMO').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/db/config/MAX_ENTRIES_PER_ADD').with_content('100') }
    it { should contain_file('/usr/openv/netbackup/FBU_READBLKS').with_content('123 456') }
  end

end
