Checklist (and a short version for the impatient)
=================================================

  * Commits:

    - Make commits of logical units.

    - Check for unnecessary whitespace with "git diff --check" before
      committing.

    - Commit using Unix line endings (check the settings around "crlf" in
      git-config(1)).

    - Do not check in commented out code or unneeded files.

    - The first line of the commit message should be a short
      description (50 characters is the soft limit, excluding ticket
      number(s)), and should skip the full stop.

    - Associate the issue in the message. The first line should include
      the issue number in the form "(#XXXX) Rest of message".

    - The body should provide a meaningful commit message, which:

      - uses the imperative, present tense: "change", not "changed" or
        "changes".

      - includes motivation for the change, and contrasts its
        implementation with the previous behavior.

    - Make sure that you have tests for the bug you are fixing, or
      feature you are adding.

    - Make sure the test suites passes after your commit:
      `bundle exec rspec spec/acceptance` More information on [testing](#Testing) below

    - When introducing a new feature, make sure it is properly
      documented in the README.md

  * Submission:

    * Pre-requisites:

      - Make sure you have a [GitHub account](https://github.com/join)

    * Preferred method:

      - Fork the repository on GitHub.

      - Push your changes to a topic branch in your fork of the
        repository. (the format ticket/1234-short_description_of_change is
        usually preferred for this project).

      - Submit a pull request to the repository in the OpenConceptConsulting
        organization.

Testing
=======

Getting Started
---------------

Our puppet modules provide [`Gemfile`](./Gemfile)s which can tell a ruby
package manager such as [bundler](http://bundler.io/) what Ruby packages,
or Gems, are required to build, develop, and test this software.

Please make sure you have [bundler installed](http://bundler.io/#getting-started)
on your system, then use it to install all dependencies needed for this project,
by running

```shell
% bundle install
Fetching gem metadata from https://rubygems.org/........
Fetching gem metadata from https://rubygems.org/..
Using rake (10.1.0)
Using builder (3.2.2)
-- 8><-- many more --><8 --
Using rspec-system-puppet (2.2.0)
Using serverspec (0.6.3)
Using rspec-system-serverspec (1.0.0)
Using bundler (1.3.5)
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

NOTE some systems may require you to run this command with sudo.

If you already have those gems installed, make sure they are up-to-date:

```shell
% bundle update
```

With all dependencies in place and up-to-date we can now run the tests:

```shell
% rake spec
```

This will execute all the [rspec tests](http://rspec-puppet.com/) tests
under [spec/defines](./spec/defines), [spec/classes](./spec/classes),
and so on. rspec tests may have the same kind of dependencies as the
module they are testing. While the module defines in its [Modulefile](./Modulefile),
rspec tests define them in [.fixtures.yml](./fixtures.yml).

Some puppet modules also come with [beaker](https://github.com/puppetlabs/beaker)
tests. These tests spin up a virtual machine under
[VirtualBox](https://www.virtualbox.org/)) with, controlling it with
[Vagrant](http://www.vagrantup.com/) to actually simulate scripted test
scenarios. In order to run these, you will need both of those tools
installed on your system.

You can run them by issuing the following command

```shell
% rake spec_clean
% rspec spec/acceptance
```

This will now download a pre-fabricated image configured in the [default node-set](./spec/acceptance/nodesets/default.yml),
install puppet, copy this module and install its dependencies per [spec/spec_helper_acceptance.rb](./spec/spec_helper_acceptance.rb)
and then run all the tests under [spec/acceptance](./spec/acceptance).

Writing Tests
-------------

XXX getting started writing tests.

Additional Resources
====================

* [General GitHub documentation](http://help.github.com/)

* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)

