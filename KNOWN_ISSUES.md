# Known Issues
## 1 - Sinatra is 404 catcher for all routes
Right now, 404s cascade past Grape to Sinatra, even for API calls.  Going to need more sophisticated Rack handling to deal with this.
