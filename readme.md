Here is the backend repo for our backend: https://github.com/Eclipse932/SyncUp_backend
It's public repo so you can clone the code to local machine and run the functional tests with the following command:

git clone https://github.com/Eclipse932/SyncUp_backend
cd SyncUp_backend
rake db:migrate
rake db:test:prepare
make func_tests