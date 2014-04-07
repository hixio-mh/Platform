#! /bin/bash
#
# Builds adefy bower components
# In future versions, this will no longer be necessary
cd public/components

cd adefy-js
npm install
grunt cdn
cd ..

cd adefy-re
npm install
grunt cdn
cd ..

cd ..

