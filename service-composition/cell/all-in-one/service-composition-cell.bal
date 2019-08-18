//
//  Copyright (c) 2019 WSO2 Inc. (http:www.wso2.org) All Rights Reserved.
//
//  WSO2 Inc. licenses this file to you under the Apache License,
//  Version 2.0 (the "License"); you may not use this file except
//  in compliance with the License.
//  You may obtain a copy of the License at
//
//  http:www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//

import ballerina/io;
import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {

        // Orders Component
    // This component deals with all the orders related functionality.
    cellery:Component airlineComponent = {
        name: "airline",
        source: {
            image: "chanakaudaya/airline_reservation_service:v5.0"
        },
        ingresses: {
            orders: <cellery:HttpApiIngress>{
                port: 9091
            }
        }
    };

    // Customers Component
    // This component deals with all the customers related functionality.
    cellery:Component carRentalComponent = {
        name: "rental",
        source: {
            image: "chanakaudaya/car_rental_service:v5.0"
        },
        ingresses: {
            customers: <cellery:HttpApiIngress>{
                port: 9093
            }
        }
    };

    // Catalog Component
    // This component deals with all the catalog related functionality.
    cellery:Component hotelComponent = {
        name: "hotel",
        source: {
            image: "chanakaudaya/hotel_reservation_service:v5.0"
        },
        ingresses: {
            catalog: <cellery:HttpApiIngress>{
                port: 9092
            }
        }
    };


    // Controller Component
    // This component deals depends on Orders, Customers and Catalog components.
    // This exposes useful functionality from the Cell by using the other three components.
    cellery:Component travelComponent = {
        name: "travel",
        source: {
            image: "chanakaudaya/travel_agency_service:v5.0"
        },
        ingresses: {
            controller: <cellery:HttpApiIngress>{
                port: 9090,
                context: "travel",
                definition: {
                    resources: [
                        {
                            path: "/",
                            method: "POST"
                        }
                    ]
                },
                expose: "global"
            }
        },
        envVars: {
            AIRLINE_HOST: { value: cellery:getHost(airlineComponent) },
            AIRLINE_PORT: { value: 80 },
            HOTEL_HOST: { value: cellery:getHost(hotelComponent) },
            HOTEL_PORT: { value: 80 },
            CAR_RENTAL_HOST: { value: cellery:getHost(carRentalComponent) },
            CAR_RENTAL_PORT: { value: 80 }
        },
        dependencies: {
            components: [airlineComponent, hotelComponent, carRentalComponent]
        }
    };

    // Cell Initialization
    cellery:CellImage serviceCompositionCell = {
        components: {
            airline: airlineComponent,
            hotel: hotelComponent,
            rental: carRentalComponent,
            travel: travelComponent
        }
    };
    io:println("Building Service Composition Cell ...");
    return cellery:createImage(serviceCompositionCell, untaint iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances) returns error? {
    cellery:CellImage serviceCompositionCell = check cellery:constructCellImage(untaint iName);
    return cellery:createInstance(serviceCompositionCell, iName, instances);
}
