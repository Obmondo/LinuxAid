require 'spec_helper'

describe 'cron::job' do
  params_cases = {
    'all minutes' => { minute: '*', should_accept: true },
    'skip minutes' => { minute: '*/3', should_accept: true },
    'integer minutes' => { minute: 31, should_accept: true },
    'simple minutes list' => { minute: '1,2,17,42', should_accept: true },
    'complex minutes list' => { minute: '1-2,5-15/3,42', should_accept: true },
    'too-large minute' => { minute: 60, should_accept: false },
    'too-small minute' => { minute: -1, should_accept: false },
    'wildcard in minute list' => { minute: '*,3', should_accept: false },
    'bad minute range start' => { minute: '-1-30', should_accept: false },
    'bad minute range end' => { minute: '30-60', should_accept: false },
    'bad minute range skip' => { minute: '1-59/0', should_accept: false },
    'all hours' => { hour: '*', should_accept: true },
    'skip hours' => { hour: '*/3', should_accept: true },
    'integer hours' => { hour: 13, should_accept: true },
    'simple hours list' => { hour: '1,2,12,23', should_accept: true },
    'complex hours list' => { hour: '1-2,3-6/3,12', should_accept: true },
    'too-large hour' => { hour: 24, should_accept: false },
    'too-small hour' => { hour: -1, should_accept: false },
    'wildcard in hour list' => { hour: '*,3', should_accept: false },
    'bad hour range start' => { hour: '-1-13', should_accept: false },
    'bad hour range end' => { hour: '12-24', should_accept: false },
    'bad hour range skip' => { hour: '1-23/0', should_accept: false },
    'all dates' => { date: '*', should_accept: true },
    'skip dates' => { date: '*/3', should_accept: true },
    'integer dates' => { date: 28, should_accept: true },
    'simple dates list' => { date: '1,2,12,31', should_accept: true },
    'complex dates list' => { date: '1-2,3-18/3,24', should_accept: true },
    'too-large date' => { date: 32, should_accept: false },
    'too-small date' => { date: 0, should_accept: false },
    'wildcard in date list' => { date: '*,3', should_accept: false },
    'bad date range start' => { date: '0-13', should_accept: false },
    'bad date range end' => { date: '12-32', should_accept: false },
    'bad date range skip' => { date: '1-30/0', should_accept: false },
    'all months' => { month: '*', should_accept: true },
    'skip months' => { month: '*/4', should_accept: true },
    'integer months' => { month: 7, should_accept: true },
    'simple months list' => { month: '1,5,7,12', should_accept: true },
    'complex months list' => { month: '1-2,4-10/2,12', should_accept: true },
    'too-large month' => { month: 13, should_accept: false },
    'too-small month' => { month: 0, should_accept: false },
    'wildcard in month list' => { month: '*,3', should_accept: false },
    'bad month range start' => { month: '0-9', should_accept: false },
    'bad month range end' => { month: '3-13', should_accept: false },
    'bad month range skip' => { month: '1-12/0', should_accept: false },
    'month name in list' => { month: '1,May,9', should_accept: false },
    'month name in range' => { month: 'Jun-Aug', should_accept: false },
    'all weekdays' => { weekday: '*', should_accept: true },
    'skip weekdays' => { weekday: '*/3', should_accept: true },
    'integer weekdays' => { weekday: 5, should_accept: true },
    'simple weekdays list' => { weekday: '0,2,5,7', should_accept: true },
    'complex weekdays list' => { weekday: '1-2,3-6/3,7', should_accept: true },
    'too-large weekday' => { weekday: 8, should_accept: false },
    'too-small weekday' => { weekday: -1, should_accept: false },
    'wildcard in weekday list' => { weekday: '*,3', should_accept: false },
    'bad weekday range start' => { weekday: '-1-7', should_accept: false },
    'bad weekday range end' => { weekday: '2-8', should_accept: false },
    'bad weekday range skip' => { weekday: '1-5/0', should_accept: false },
    'day name in list' => { weekday: '1,Wed,6', should_accept: false },
    'day name in range' => { weekday: 'Mon-Fri', should_accept: false },
    'user with dots in name' => { user: 'admin.master', minute: '*', should_accept: true },
    'user with slash in name' => { user: 'admin/master', minute: '*', should_accept: false },
    'user with backslash in name' => { user: 'admin\master', minute: '*', should_accept: false }
  }
  let(:title) { 'mysql_backup' }

  context 'job with default values' do
    let(:params) { { command: 'mysqldump -u root test_db >some_file' } }
    let(:cron_timestamp) { get_timestamp(params) }

    it do
      is_expected.to contain_file("job_#{title}").with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'path'    => "/etc/cron.d/#{title}"
      ).with_content(
        %r{\n#{cron_timestamp}\s+}
      ).with_content(
        %r{\s+#{params[:command]}\n}
      )
    end
  end

  context 'job with custom values' do
    let(:params) do
      {
        minute: '45',
        hour: '7',
        date: '12',
        month: '7',
        weekday: '*',
        environment: ['MAILTO="root"', 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"'],
        user: 'admin',
        mode: '0644',
        description: 'Mysql backup',
        command: 'mysqldump -u root test_db >some_file'
      }
    end
    let(:cron_timestamp) { get_timestamp(params) }

    it do
      is_expected.to contain_file("job_#{title}").with(
        'owner'   => 'root',
        'mode'    => params[:mode]
      ).with_content(
        %r{\n#{params[:environment].join('\n')}\n}
      ).with_content(
        %r{\n#{cron_timestamp}\s+}
      ).with_content(
        %r{\s+#{params[:user]}\s+}
      ).with_content(
        %r{\s+#{params[:command]}\n}
      ).with_content(
        %r{\n# #{params[:description]}\n}
      )
    end
  end

  context 'job with ensure set to absent' do
    let(:params) do
      {
        ensure: 'absent'
      }
    end

    it do
      is_expected.to contain_file("job_#{title}").with('ensure' => 'absent')
    end
  end

  # Multiple test cases for variations on time field values
  params_cases.each do |desc, p|
    context "job with #{desc}" do
      let(:params) { p.reject { |k, _v| k == :should_accept } .update(command: '/bin/true') }
      let(:cron_timestamp) { get_timestamp(params) }

      if p[:should_accept]
        it do
          is_expected.to compile
          is_expected.to contain_file("job_#{title}").with_content(%r{\n#{cron_timestamp}\s+})
        end
      else
        it { is_expected.to compile.and_raise_error(%r{.*}) }
      end
    end
  end

  context 'job with special parameter set' do
    let(:params) do
      {
        command: '/usr/bin/sleep 10',
        special: 'reboot'
      }
    end

    it do
      is_expected.to compile
      is_expected.to contain_file("job_#{title}").with_content(%r{^@reboot root /usr/bin/sleep 10$})
    end
  end
end
