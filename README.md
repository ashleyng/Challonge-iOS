# Challonge

[![CI Status](https://img.shields.io/travis/ashleyng/Challonge-iOS.svg?style=flat)](https://travis-ci.org/ashleyng/Challonge-iOS)
[![Code Coverage Status](https://codecov.io/gh/ashleyng/Challonge-iOS/branch/master/graphs/badge.svg)](https://codecov.io/gh/ashleyng/Challonge-iOS/branch/master)

<a href="https://itunes.apple.com/us/app/tournymngr/id1448058184?mt=8">
  <img src="assets/app-store-badge.png" height="55">
</a>

# Getting Started

To get started you will need to have a [challonge account](challonge.com) and an API key. You can get your API from the settings page once logged into the website.

## Installation
```sh
git clone git@github.com:ashleyng/Challonge-iOS.git
cd Challonge-iOS
bundle install
bundle exec pod install
open Challonge.xcworkspace
```

During installation you'll be asked for Instabug keys by `cocoapods-keys`, you can use any random value for debugging. The real values are only required for App Store submissions.
```sh
 bundle exec pod install 

 CocoaPods-Keys has detected a keys mismatch for your setup.
 What is the key for InstabugLive
 > <Random Value>

Saved InstabugLive to Challonge.
 What is the key for InstabugBeta
 > <Random Value>
```