### Building a cell with service composition cell

![Service_Composition_One_Cell](resources/service-composition-one-cell.png)

1) Go to **/cell/all-in-one** folder and build the cell with the below command

**cellery build service-composition-cell.bal chanakaudaya/service-composition-cell:v5.0** 

2) Now run the cell image with the below command

**cellery run chanakaudaya/service-composition-cell:v5.0 -n service-composition-cell-v50** 

3) Go to [API Store](https://wso2-apim/store/) and subscribe to the API with the name "service-composition-cell-v50" and generate an access token. Once the token is generated, execute the below command with the token.

**curl -v -X POST -d '{"Name":"Bob", "ArrivalDate":"12-03-2018",
   "DepartureDate":"13-04-2018", "Preference":{"Airline":"Business", 
   "Accommodation":"Air Conditioned", "Car":"Air Conditioned"}}' \
   "https://wso2-apim-gateway/service-composition-cell-v50/travel" -H "Content-Type:application/json" -H "Authorization: Bearer f9c43e34-c116-3367-b286-ef59a97b1f6c" -k** 

4) You should get a response with below text

**{"Message":"Congratulations! Your journey is ready!!"}** 
