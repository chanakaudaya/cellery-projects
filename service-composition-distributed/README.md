### Building a cell with service composition cell in distributed mode

1) Go to /cell folder and build the cells with the below command
sh build.sh

2) Now run the cell image with the below command
cellery run chanakaudaya/service-composition-distributed:v63 -n service-composition-distributed-cell-v63 -l airline:airline-cell -l hotel:hotel-cell -l rental:rental-cell -d -y

3) Go to API Store and subscribe to the API with the name "service-composition-distributed-cell-v63" and generate an access token. Once the token is generated, execute the below command with the token.
curl -v -X POST -d '{"Name":"Bob", "ArrivalDate":"12-03-2018",
   "DepartureDate":"13-04-2018", "Preference":{"Airline":"Business", 
   "Accommodation":"Air Conditioned", "Car":"Air Conditioned"}}' \
   "https://wso2-apim-gateway/service-composition-distributed-cell-v63/travel" -H "Content-Type:application/json" -H “Authorization: Bearer f9c43e34-c116-3367-b286-ef59a97b1f6c” -k

4) You should get a response with below text
{"Message":"Congratulations! Your journey is ready!!"}
