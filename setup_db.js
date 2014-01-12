use adefy_cloud_testing;
db.dropDatabase();

// Setup db user
db.addUser("adefy_cloud", "GFtEA468aF73nYZh");

// Setup test users
testUser = {
  "email": "test@test.com",
  "fname": "Testy",
  "funds": 0,
  "hash": "u9ZaFCuqEWE2wslmKJECgA==",
  "limit": "0",
  "lname": "Trista",
  "password": "$2a$10$llkTZagDuZkhY478zjuLWea4pUkPBygitzrNcNy11nbwHYLQqhS8q",
  "permissions": 7,
  "session": "244b1f0-1ce4-8c0",
  "username": "testy-trista",
  "version": 1
};

testAdminUser = {
  "email": "test@test.com",
  "fname": "Testy",
  "funds": 0,
  "hash": "AWV/mgv1VVPA+MEWvS/jMQ==",
  "limit": "0",
  "lname": "Trista Admin",
  "password": "$2a$10$51z8xVel4HABCIZNo/Rk1uS.IbbFrlzem5vpw76ddo2qsw0jYEfG6",
  "permissions": 0,
  "session": "97423b4-2581-23cf",
  "username": "testy-trista-admin",
  "version": 1
};

db.users.insert(testUser);
db.users.insert(testAdminUser);
