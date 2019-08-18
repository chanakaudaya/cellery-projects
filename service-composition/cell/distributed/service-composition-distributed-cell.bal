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


    // Controller Component
    // This component deals depends on Orders, Customers and Catalog components.
    // This exposes useful functionality from the Cell by using the other three components.
    cellery:Component travelComponent = {
        name: "travel",
        source: {
            image: "chanakaudaya/travel_agency_service_distributed:v6.3"
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
            AIRLINE_HOST: { value: "" },
            AIRLINE_PORT: { value: 80 },
            AIRLINE_URL: { value: ""},
            HOTEL_HOST: { value: "" },
            HOTEL_PORT: { value: 80 },
            HOTEL_URL: { value: ""},
            CAR_RENTAL_HOST: { value: "" },
            CAR_RENTAL_PORT: { value: 80 },
            CAR_RENTAL_URL: { value: ""}
        },
        dependencies: {
            cells: {
                airline: <cellery:ImageName>{ org: "chanakaudaya", name: "airline-cell", ver: "v64" },
                hotel: <cellery:ImageName>{ org: "chanakaudaya", name: "hotel-cell", ver: "v64" },
                rental: <cellery:ImageName>{ org: "chanakaudaya", name: "rental-cell", ver: "v64" }
            }
        }
    };

    travelComponent.envVars.AIRLINE_HOST.value =
    <string>cellery:getReference(travelComponent, "airline").gateway_host;
    travelComponent.envVars.HOTEL_HOST.value =
    <string>cellery:getReference(travelComponent, "hotel").gateway_host;
    travelComponent.envVars.CAR_RENTAL_HOST.value =
    <string>cellery:getReference(travelComponent, "rental").gateway_host;

    travelComponent.envVars.AIRLINE_URL.value =
    <string>cellery:getReference(travelComponent, "airline").airline_api_url;
    travelComponent.envVars.HOTEL_URL.value =
    <string>cellery:getReference(travelComponent, "hotel").hotel_api_url;
    travelComponent.envVars.CAR_RENTAL_URL.value =
    <string>cellery:getReference(travelComponent, "rental").rental_api_url;

    // Cell Initialization
    cellery:CellImage serviceCompositionCell = {
        components: {
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
