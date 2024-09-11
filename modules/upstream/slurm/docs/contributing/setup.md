There is a number of pre-requisite programs / framework you shall install to be able to correctly contribute to this Puppet module.

### Git Branching Model

The Git branching model for this repository follows the guidelines of [gitflow](http://nvie.com/posts/a-successful-git-branching-model/).
In particular, the central repository holds two main branches with an infinite lifetime:

* `production`: the branch holding   tags of the successive releases of this tutorial 
* `devel`: the main branch where the sources are in a state with the latest delivered development changes for the next release. This is the *default* branch you get when you clone the repository, and the one on which developments will take places.

You should therefore install [git-flow](https://github.com/nvie/gitflow), and probably also its associated [bash completion](https://github.com/bobthecow/git-flow-completion).

### Ruby, [RVM](https://rvm.io/) and [Bundler](http://bundler.io/)

The various operations that can be conducted from this repository are piloted
from a `Rakefile` and assumes you have a running Ruby installation.

The bootstrapping of your repository is based on [RVM](https://rvm.io/), **thus
ensure this tools are installed on your system** -- see
[installation notes](https://rvm.io/rvm/install).

The ruby stuff part of this repository corresponds to the following files:

* `.ruby-{version,gemset}`: [RVM](https://rvm.io/) configuration, use the name of the
  project as [gemset](https://rvm.io/gemsets) name
* `Gemfile[.lock]`: used by `[bundle](http://bundler.io/)`

### Repository Setup

Then, to make your local copy of the repository ready to use the [git-flow](https://github.com/nvie/gitflow) workflow and the local [RVM](https://rvm.io/)  setup, you have to run the following commands once you cloned it for the first time:

      $> gem install bundler    # assuming it is not yet available
	  $> bundle install
	  $> rake -T                # To list the available tasks
      $> rake setup

You probably wants to activate the bash-completion for rake tasks.
I personnaly use the one provided [here](https://github.com/ai/rake-completion)

Also, some of the tasks are hidden. Run `rake -T -A` to list all of them.

### RSpec tests

A set of unitary tests are defined to validate the different function of my library using [Rspec](http://rspec.info/)

You can run these tests by issuing:

	$> rake rspec  # NOT YET IMPLEMENTED

By conventions, you will find all the currently implemented tests in the `spec/` directory, in files having the `_spec.rb` suffix. This is expected from the `rspec` task of the `Rakefile`.

**Important** Kindly stick to this convention, and feature tests for all   definitions/classes/modules you might want to add.
