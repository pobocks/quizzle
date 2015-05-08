#Quizzle

Quizzle is a read/write API and web view for questions and answers.

## Requirements

Quizzle was developed and is tested on:

* Ruby 2
* sqlite3
* thin

Other SQL dbs and web servers should be more or less plug-in replacements.

The core components of its application stack are:

* Grape as an API framework
* Sinatra as a web framework
* Rack as a web abstraction layer
* ActiveRecord as an ORM
* HTTP Basic Auth as authentication for the web component
* API key as authentication for the API component

## Installation

1. Fetch latest code from *git location TBD*
2. Populate .env with a value for the API key and basic auth name:password pairs.  Example values:

        ```
        API_KEY=thirtycharsormorefromyourfavoritesourceofrandomness
        BASIC_AUTH_PAIRS=oswald_cobblepot:p3ngu1n;santa_anna:alamo_rental
        ```
3. `bundle install` in root directory
4. `rackup` in root directory to start app for first time.
5. TODO: DB setup
6. TODO: Data loading

## API

TBD where `D == *D*esign
