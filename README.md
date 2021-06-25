# CheckHigh App

Web application for CheckHigh system that allows teams to share sensitive files such as configuration information, credentials, etc.

Please also note the Web API that it uses: https://github.com/Crypto-Alpha/CheckHigh_api

## Install

Install this application by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

- When wsl is installing or app is loading pdf file, it may have problem with `gem 'wkhtmltopdf-binary'`. 
    - err: `error while loading shared libraries: libjpeg.so.8: cannot open shared object file: No such file or directory`
    - solve: shell run `sudo apt-get install libjpeg-turbo8`
    - [source](https://forums.fast.ai/t/solved-importerror-libjpeg-so-8-cannot-open-shared-object-file-on-wsl/8303)


## Test

This web app does not contain any tests yet :(

## Execute

Launch the application using:

```shell
rake run:dev
```

The application expects the API application to also be running (see `config/app.yml` for specifying its URL)

## Heroku

remote control
```
heroku git:remote -a checkhigh-api
```

restart
```
git push heroku master
heroku restart
```
