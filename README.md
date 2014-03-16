Ironwood
========

A game created for the 2014 

Install
-------

Have [Ruby 2.1](https://www.ruby-lang.org/en/downloads/) installed, cd to the
Ironwood directory, and run:

    bundle install

...to download and install all the game's dependencies. You will probably need some kind of curses headers/libraries installed for this to work, but I honestly don't know what the package is called. Try `apt-get install libncurses` or `brew install ncurses` as appropriate.

Then run the game with:

    bundle exec ./ironwood.rb


It assumes you have a terminal at least 80 columns wide that you never resize
during gameplay. Have fun!
