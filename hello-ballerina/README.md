### Building a cell with hello world ballerina program

1) Go to /src folder and execute the below command
ballerina build hello_service.bal

2) The above command will generate the ballerina executable and docker images in local docker repository. Push this image to docker hub.
docker push chanakaudaya/helloworld:v6.0

3) Go to /cell folder and build the cell with the below command
cellery build hello-ballerina-cell.bal chanakaudaya/hello-ballerina-cell:v6.0

4) Now run the cell image with the below command
cellery run chanakaudaya/hello-ballerina-cell:v6.0 -n hello-ballerina-cell-v60

5) Go to API Store and subscribe to the API with the name "hello-ballerina-cell-v60" and generate an access token. Once the token is generated, execute the below command with the token.
curl -H "Authorization: Bearer f9c43e34-c116-3367-b286-ef59a97b1f6c" https://wso2-apim-gateway/hello-ballerina-cell-v60/hello/ -k

6) You should get a response with below text
Hello Ballerina 123!
