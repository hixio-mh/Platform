///
/// Setup admin db if needed
///
use admin;
if(db.system.users.find().count() == 0) {
  db.addUser("admin", "6U22iEbEorpL6sBytss5hsSOLr8ud3rlAg2PyyplW7oJGTkK");
}

///
/// Authenticate with mongo
///
use admin;
db.auth("admin", "6U22iEbEorpL6sBytss5hsSOLr8ud3rlAg2PyyplW7oJGTkK");

///
/// Add database users if needed
///
use adefy_development;
if(db.system.users.find().count() == 0) {
  db.addUser("adefy", "JPJsehsZkrBe15xIcQH419C2ZRoc4hg4uA90KVgjFkDbnKpQ");
}

use adefy_staging;
if(db.system.users.find().count() == 0) {
  db.addUser("adefy", "izSMqB3pcwxEp6oE7m4FuceTJ7MwUkOn6jgq2kx37k32gBcH");
}

use adefy;
if(db.system.users.find().count() == 0) {
  db.addUser("adefy", "CdZcBjub3NRpoQNPhlrFQ6sZMgXI93DZGUE1CwkIgl8FjWCn");
}

///
/// Testing DB setup (insert test users)
///
use adefy_testing;
db.dropDatabase();
db.addUser("adefy", "l3xzkDSBhGsAGhGpDWTqOX7NrQWyeNI3CXEfIiyMA2ckKbOn");

testUser = {
  "email": "test@test.com",
  "funds": 0,
  "password": "$2a$10$llkTZagDuZkhY478zjuLWea4pUkPBygitzrNcNy11nbwHYLQqhS8q",
  "permissions": 7,
  "username": "testy-trista",
  "version": 1,
  "apikey": "DyF5l5tMS2n3zgJDEn1OwRga"
};

testAdminUser = {
  "email": "test@test.com",
  "funds": 0,
  "password": "$2a$10$51z8xVel4HABCIZNo/Rk1uS.IbbFrlzem5vpw76ddo2qsw0jYEfG6",
  "permissions": 0,
  "username": "testy-trista-admin",
  "version": 1,
  "apikey": "DyF5l5tMS2n3zgJDEn1OwRga"
};

db.users.insert(testUser);
db.users.insert(testAdminUser);
