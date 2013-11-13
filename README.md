# Solidifier

Website content archiver.

Intended to record (“solidify”) content from a given URL into a local directory.

By [Grant Neufeld](http://grantneufeld.ca/).


## Installation

### Prerequisites

You must have [ruby](https://www.ruby-lang.org/) installed (built with MRI 2.0, untested with other distributions). You may want to use something like [RVM](https://rvm.io/) to manage installation of ruby.

Depending on your ruby setup, you may need to prefix the `gem` calls that follow with `sudo`.

Make sure your [ruby gem](http://rubygems.org/) system is up to date:

    gem update --system

Make sure you have [Bundler](http://bundler.io/) for installing gems:

    gem install bundler

### Setup

Put the entire project directory where you want it on your system (e.g., somewhere like `~/projects/solidifier`).

The following commands should be issued from within the root the project directory (e.g., `~/projects/solidifier`).

Run the following command to ensure you have the required gems (and the required versions of those gems):

    bundle


## Usage

Call the script `bin/solidifier --help` to get current command instructions.


## Development

This project uses rspec for tests, and guard to auto-run tests continuously as changes are made.

To start up guard:

    bundle exec guard -i


## License

Solidifier is released under:

> The MIT License (MIT)
>
> Copyright © 2013 Grant Neufeld.
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.
