## SocialApp

It's the next big thing!  Actually it's pretty unimpressive.  But it does contain some
useful build automation scripts.

## Prerequisites

This build system requires the following:

- Ruby
- Bundler
- Rake

Run `bundle install` to get the remaining dependencies.

## Building the app

A simple Xcode build:

````
rake xcode:build
````

Running tests:

````
rake test
````

Building an IPA:

````
rake build_ipa
````

Generating documentation:

````
rake docs
````

## Continuous Integration Servers

On a ci server, you can run `rake ci` to automatically install provisioning profiles & 
certificates, build an ipa, zip dsyms, and generate documentation.

See the slides [here](http://speakerdeck.com/subdigital/ios-build-automation-with-jenkins).






