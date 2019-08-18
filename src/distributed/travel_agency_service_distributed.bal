// A system module containing protocol access constructs
// Module objects referenced with 'http:' in code
import ballerina/http;
import ballerina/io;
import ballerinax/docker;
import ballerina/log;
import ballerina/config;

@docker:Config {
    registry:"chanakaudaya",
    name:"travel_agency_service_distributed",
    tag:"v6.3"
}

@docker:Expose {}
listener http:Listener cmdListener = new(9090);

// Reads a configuration as a string.
string airlineHost = config:getAsString("AIRLINE_HOST"); // Returns “” (i.e., empty string) if the configuration 
//is not available.

// Reads a configuration as an integer.
int airlinePort = config:getAsInt("AIRLINE_PORT"); // Returns 0 if the configuration is not available.

string airlineURL = config:getAsString("AIRLINE_URL");

// Reads a configuration as a string.
string hotelHost = config:getAsString("HOTEL_HOST"); // Returns “” (i.e., empty string) if the configuration 
//is not available.

// Reads a configuration as an integer.
int hotelPort = config:getAsInt("HOTEL_PORT"); // Returns 0 if the configuration is not available.

string hotelURL = config:getAsString("HOTEL_URL");

// Reads a configuration as a string.
string carRentalHost = config:getAsString("CAR_RENTAL_HOST"); // Returns “” (i.e., empty string) if the configuration 
//is not available.

// Reads a configuration as an integer.
int carRentalPort = config:getAsInt("CAR_RENTAL_PORT"); // Returns 0 if the configuration is not available.

string carRentalURL = config:getAsString("CAR_RENTAL_URL");

int x = 100;

// Client endpoint to communicate with Airline reservation service
// http:Client airlineReservationEP = new("http://"+airlineHost+ ":" +airlinePort+ "/airline");

http:Client airlineReservationEP = new(airlineURL);


// Client endpoint to communicate with Hotel reservation service
// http:Client hotelReservationEP = new("http://"+hotelHost+ ":" +hotelPort+ "/hotel");
http:Client hotelReservationEP = new(hotelURL);

// Client endpoint to communicate with Car rental service
// http:Client carRentalEP = new("http://"+carRentalHost+ ":" +carRentalPort+ "/car");
http:Client carRentalEP = new(carRentalURL);

@http:ServiceConfig {
   basePath: "/"
}
service hello on cmdListener {

    # A resource is an invokable API method
    # Accessible at '/hello/sayHello
    # 'caller' is the client invoking this resource 
    # Description
    #
    # + caller - caller Parameter Description 
    # + inRequest - inRequest Parameter Description 
    # + return - Return Value Description
    @http:ResourceConfig {
        path: "/",
        methods:["POST"],
        consumes: ["application/json"],
        produces: ["application/json"]
    }
    resource function sayHello(http:Caller caller, http:Request inRequest) returns error? {
        // log:printError("request received with " + x + " variable", err = ());

        // // Create object to carry data back to caller
        // http:Response response = new;

        // // Set a string payload to be sent to the caller
        // response.setTextPayload("Hello Ballerina 123!");

        // // Send a response back to caller
        // // -> indicates a synchronous network-bound call
        // error? result = caller -> respond(response);
        // if (result is error) {
        //     io:println("Error in responding", result);
        // }    

        log:printError("Request received at travel service");
        http:Response outResponse = new;
        json inReqPayload = {};
        // Json payload format for an http out request
        json outReqPayload = {"Name":"", "ArrivalDate":"", "DepartureDate":"", "Preference":""};

        // Try parsing the JSON payload from the user request
        var payload = inRequest.getJsonPayload();
        if (payload is json) {
            // Valid JSON payload
            inReqPayload = payload;
        } else {
            // NOT a valid JSON payload
            outResponse.statusCode = 400;
            outResponse.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
            var result = caller->respond(outResponse);
            handleError(result);
            return;
        }

        outReqPayload.Name = inReqPayload.Name;
        outReqPayload.ArrivalDate = inReqPayload.ArrivalDate;
        outReqPayload.DepartureDate = inReqPayload.DepartureDate;
        json airlinePreference = inReqPayload.Preference.Airline;
        json hotelPreference = inReqPayload.Preference.Accommodation;
        json carPreference = inReqPayload.Preference.Car;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (outReqPayload.Name == () || outReqPayload.ArrivalDate == () || outReqPayload.DepartureDate == () ||
            airlinePreference == () || hotelPreference == () || carPreference == ()) {
            outResponse.statusCode = 400;
            outResponse.setJsonPayload({"Message":"Bad Request - Invalid Payload"});
            var result = caller->respond(outResponse);
            handleError(result);
            return;
        }


        // Reserve airline ticket for the user by calling Airline reservation service
        // construct the payload
        json outReqPayloadAirline = outReqPayload;
        outReqPayloadAirline.Preference = airlinePreference;

        // log:printError("Airline host is " + airlineHost + " Airline port is " + airlinePort, err = ());
        log:printError("Airline URL is " + airlineURL, err = ());
        // Send a post request to airlineReservationService with appropriate payload and get response
        http:Response inResAirline = check airlineReservationEP->post("/reserve", untaint outReqPayloadAirline);

        // Get the reservation status
        var airlineResPayload = check inResAirline.getJsonPayload();
        string airlineStatus = airlineResPayload.Status.toString();
        // If reservation status is negative, send a failure response to user
        if (airlineStatus.equalsIgnoreCase("Failed")) {
            outResponse.setJsonPayload({"Message":"Failed to reserve airline! " +
                    "Provide a valid 'Preference' for 'Airline' and try again"});
            var result = caller->respond(outResponse);
            handleError(result);
            return;
        }


        // Reserve hotel room for the user by calling Hotel reservation service
        // construct the payload
        json outReqPayloadHotel = outReqPayload;
        outReqPayloadHotel.Preference = hotelPreference;

        // Send a post request to hotelReservationService with appropriate payload and get response
        http:Response inResHotel = check hotelReservationEP->post("/reserve", untaint outReqPayloadHotel);

        // Get the reservation status
        var hotelResPayload = check inResHotel.getJsonPayload();
        string hotelStatus = hotelResPayload.Status.toString();
        // If reservation status is negative, send a failure response to user
        if (hotelStatus.equalsIgnoreCase("Failed")) {
            outResponse.setJsonPayload({"Message":"Failed to reserve hotel! " +
                    "Provide a valid 'Preference' for 'Accommodation' and try again"});
            var result = caller->respond(outResponse);
            handleError(result);
            return;
        }

        // Renting car for the user by calling Car rental service
        // construct the payload
        json outReqPayloadCar = outReqPayload;
        outReqPayloadCar.Preference = carPreference;

        // Send a post request to carRentalService with appropriate payload and get response
        http:Response inResCar = check carRentalEP->post("/rent", untaint outReqPayloadCar);

        // Get the rental status
        var carResPayload = check inResCar.getJsonPayload();
        string carRentalStatus = carResPayload.Status.toString();
        // If rental status is negative, send a failure response to user
        if (carRentalStatus.equalsIgnoreCase("Failed")) {
            outResponse.setJsonPayload({"Message":"Failed to rent car! " +
                    "Provide a valid 'Preference' for 'Car' and try again"});
            var result = caller->respond(outResponse);
            handleError(result);
            return;
        }


        // If all three services response positive status, send a successful message to the user
        outResponse.setJsonPayload({"Message":"Congratulations! Your journey is ready!!"});
        var result = caller->respond(outResponse);
        handleError(result);
        return ();
        }
}

function handleError(error? result) {
    if (result is error) {
        log:printError(result.reason(), err = result);
    }
}