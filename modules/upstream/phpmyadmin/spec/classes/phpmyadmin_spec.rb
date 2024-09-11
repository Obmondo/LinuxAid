require 'spec_helper'

describe 'phpmyadmin', type: :class do
  context 'with default parameters' do
    it do
      should contain_vcsrepo('/srv/phpmyadmin').with(
               ensure: :present,
               provider: 'git',
               source: 'https://github.com/phpmyadmin/phpmyadmin.git',
               user: 'www-data',
               revision: 'origin/STABLE',
               depth: 0)
    end
    it do
      should contain_file('phpmyadmin-conf').with(
               owner: 'www-data',
               path: '/srv/phpmyadmin/config.inc.php')
    end
  end

  context 'with custom parameters' do
    let :params do
      {
        path: '/srv/myadmin',
        user: 'custom-user',
        revision: 'origin/master',
        depth: 1
      }
    end

    it do
      should contain_vcsrepo('/srv/myadmin').with(
               ensure: :present,
               provider: 'git',
               source: 'https://github.com/phpmyadmin/phpmyadmin.git',
               user: 'custom-user',
               revision: 'origin/master',
               depth: 1)
    end
    it do
      should contain_file('phpmyadmin-conf').with(
               owner: 'custom-user',
               path: '/srv/myadmin/config.inc.php')
    end
  end
end
