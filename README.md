This is a REST API made in Rails that periodically fetches data from the Chilecompra API and stores it in a Postgres DB so it can be queried/analyzed.

There is a live demo here:
  https://buscadorchilecompra.info/

User: "example@example3.com"
Password: "password"

Or if you prefer you can sign up normally

Currently the app fetches data at 8AM, 11AM, 3PM, 7PM

Installing the app:

- install PostgreSQL [Tutorial here](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04)
- git clone
- bundle install
- rails db:setup
- rails db:seed
- rails test
- config environment variables (see $REPO_ROOT/config/puma.service.example)
- rails server -p 3001 (Assuming you are using [this frontend](https://github.com/eugenioLopezRamos/buscador-chilecompra-frontend))


The app uses Resque for executing background jobs, which are scheduled with
resque-scheduler, whose workers are managed by resque-pool, and those processes
are managed by [God](http://godrb.com/)
It also uses Redis (which is a requirement of Resque) to cache some data, for
example, key-value pairs of government entities ("organismos públicos")

The frontend & the backend communicate using NGINX as a reverse proxy.
An example config file has been included in $REPO_ROOT/config/nginx.conf.example

For gzipping with nginx, an example gzip.conf file has been included in 
$REPO_ROOT/config/gzip.conf.example

For enabling god as a daemon, an example god.service file has been included in
$REPO_ROOT/config/god.service.example

For enabling puma as a daemon, an example puma.service file has been included in
$REPO_ROOT/config/puma.service.example



