// A system module containing protocol access constructs
// Module objects referenced with 'http:' in code
import ballerina/http;
import ballerina/io;
import ballerinax/docker;
import ballerina/log;
import ballerina/config;

@docker:Config {
    registry:"chanakaudaya",
    name:"helloworld",
    tag:"v6.0"
}

@docker:Expose {}
listener http:Listener cmdListener = new(9090);

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
    @http:ResourceConfig {
        path: "/",
        methods:["GET"]
    }
    resource function sayHello(http:Caller caller, http:Request inRequest) {
        // Create object to carry data back to caller
        http:Response response = new;

        // Set a string payload to be sent to the caller
        response.setTextPayload("Hello Ballerina 123!");

        // Send a response back to caller
        // -> indicates a synchronous network-bound call
        error? result = caller -> respond(response);
        if (result is error) {
            io:println("Error in responding", result);
        }    

    }
}
