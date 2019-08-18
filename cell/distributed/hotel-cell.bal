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
    cellery:Component hotelComponent = {
        name: "hotel",
        source: {
            image: "chanakaudaya/hotel_reservation_service_distributed:v6.3"
        },
        ingresses: {
            catalog: <cellery:HttpApiIngress>{
                port: 9092,
                context: "hotel",
                definition: {
                    resources: [
                        {
                            path: "/reserve",
                            method: "POST"
                        }
                    ]
                },
                expose: "local"
            }
        }
    };

    // Cell Initialization
    cellery:CellImage hotelComponentCell = {
        components: {
            hotel: hotelComponent
        }
    };
    io:println("Building Airline Service Cell ...");
    return cellery:createImage(hotelComponentCell, untaint iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances) returns error? {
    cellery:CellImage hotelComponentCell = check cellery:constructCellImage(untaint iName);
    return cellery:createInstance(hotelComponentCell, iName, instances);
}
