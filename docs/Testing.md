Testing the Adefy platform
=====================================

Unit tests are present in `src/tests/`, and should test every route provided by the application, along with all non-trivial behaviour. To run the tests, either use `grunt test`, or manually run `mocha --compilers coffee:coffee-script --reporter nyan src/tests/*`

Tests will *not* run in production!
-----------------------------------
The test users should only ever be present on development and staging machines! On that note, the credentials are:

Normal user
* Username: `testy-trista`
* Password: `AvPV52ujHpmhUJjzorBx7aixkrIIKrca`

Admin user
* Username: `testy-trista-admin`
* Password: `x7aixkrIIKrcaZAvPV52ujHpmhUJjzor`