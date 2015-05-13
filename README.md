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

Skip and Limit are in terms of individual records. Limit has a hard max of 100 by default, but this is overridable via environment.

This API returns JSON, could trivially support JSONP (Grape supports it, haven't done because there shouldn't be clients on different domains at this point)

### Collection Methods
| Route | Method | Params | Desc |
|-------|--------|--------|------|
| `/questions` | *GET* | *int* limit, *int* offset | Index of questions in creation order |
| `/questions/search` | *GET* |*int* limit, *int* offset, *str* field, *str* q | Index of questions that match search criteria in creation order |

Where param definitions are:

| Param | Definition |
|-------|------------|
| limit | Integer, number of records to return, maximum |
| offset | Integer, number of records to skip from beginning of query |
| field | String in set `[questions, answers, distractors]`, narrow search to field |
| q | String for search.  Searched with LIKE, wildcards at either end. Fields are separated in the cache column by `\v`, so space-separated values should only match if whole token is in the same field |

#### Example Output
```json
    {"results":
      [
        {"id": 3,
         "value": "Who let the dogs out?",
         "responses": [{"value": "Larry"}, {"value": "Curly"}, {"value": "Moe", "correct": true}]
        },
      ...more responses here
      ]
    }
```

### Member Methods
| Route          | Method | Description                                                            |
| -------------- | ------ | ---------------------------------------------------------------------- |
| /questions     | POST   | Create new question from JSON representation                           |
| /questions/:id | GET    | Return JSON representation of individual question                      |
| /questions/:id | DELETE | Delete a question. Associated answer and distractors are also deleted. |
| /questions/:id | PUT    | Update a question, replacing all values except id                      |

Any operation that alters the records (Create, Update, Destroy) requires an API key.  This is set in the `.env` file, and passed into the application via the `X-Api-Key:` header.

Create and Update expect POST and PUT requests with valid JSON bodies of form:

```json
    {"value": "What is question text?",
     "answer": "What is answer text?",
     "distractors": [ "These", "are", "wrong", "answers"]}
```

Member routes return records in the following format:

```json
    {"result":
      {"value": "Question?",
       "responses": [
         {"value": "Answer", "correct": true},
         {"value": "Distractor", "correct": false}],
    },
    "status": "OK"
    }
```
