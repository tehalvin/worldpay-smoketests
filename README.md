# Worldpay Smoke Tests

## Exercising Worldpay Endpoints

* download the Postman application https://www.getpostman.com/
* import the file {dir}/resource/postman/collection/worldpay.postman-collection.json
* import the file {dir}/resource/postman/environment/worldpay_environment.json

### running newman
## worldpay smoke tests
* ensure that the expected authentication keys are set as environment variables:
```
export WUSERNAME="$VALUE"	
export WXMLPASSWORD="$VALUE"
```

* run the command `./run-smoke-test.sh -e $ENV` (see `./run-smoke-test.sh -h` for supported environment arguments)