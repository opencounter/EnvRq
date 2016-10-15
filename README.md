#EnvRq

Simple environment variable validation / documentation in ~100 LOC.

##Features
* Severity levels (Info, Warning, Fatal).
* Type checking
* Optional ENV variable descriptions.
* Overidable issue handlers (by severity level).

##Install
Add to your Gemfile and bundle.
```
gem "env_rq", git: "https://github.com/opencounter/EnvRq"
```

##Usage
```
require('env_rq')

EnvRq.validate do |e|
  # expect ENV_WITH_DESC to exist and warn if not (prints to stout in orange)
  # showing description.
  e.warn("ENV_WITH_DESC", desc: "Airbrake project to assoicate errors with")

  # expect INT_ENV to be of type integer
  e.warn("INV_ENV", type: :int)
  # and URL_ENV to be a valid URL
  e.warn("URL_ENV", type: :url)

  # expect MISSING_ENV not to be set and print (in blue) if it is
  e.info("MISSING_ENV", desc: "this env is no longer used", exclude: true)

  # checks that apply only in production
  unless Rails.env.production?
    # print in red and raise if this ENV is set!
    e.fatal("NEVER_SET_ENV", desc: "OH MY GOODNESS", exclude: true)
  end

  # override the warn level handler to send issues to Airbrake
  send_to_airbrake = lambda do |issues|
    issues_string = issues.map { |i| i[:requirement].env_var }.join(", ")
    Airbrake.notify("Missing required environment variables\n#{issues_string}" )
  end
  e.handleIssues(:warn, send_to_airbrake)
```

##FAQ
No the 100 LOC count does not include the tests... sheesh.
