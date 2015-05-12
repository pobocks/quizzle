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
2. Create a text file named .env in the root folder, with values for an API key and name:password pairs for basic auth if desired.

        ```
        API_KEY=thirtycharsormorefromyourfavoritesourceofrandomness
        BASIC_AUTH_PAIRS=oswald_cobblepot:p3ngu1n;santa_anna:alamo_rental
        ```

3. `bundle install` in root directory
4. `bundle exec rake db:schema:load`
5. `rackup` in root directory to start app for first time.
6. To load a csv file, run `bundle exec rake quizzle:import CSV=path/to/my/file.csv`

## API

The API is powered by Grape, which provides versioning, parameter conversion/validation, etc.

It's mounted at `http://my-app.host/api`.  Versioning is handled by including it in the `Accept:` header, as per the documentation [here](https://github.com/intridea/grape#header), but it has a sensible default, and there's only one version.

Any operation that alters the records (Create, Update, Destroy) requires an API key.  This is set in the `.env` file, and passed into the application via the `X-Api-Key:` header.

Create and Update expect POST and PUT requests with valid JSON bodies.
