//
//  JWTAccessTokenAdapter.swift
//  CleanSky
//
//  Created by Vladimir Korolev on 15/05/2019.
//  Copyright © 2019 Vladimir Brejcha. All rights reserved.
//

import Foundation
import Alamofire

class CustomRequestRetrier: RequestRetrier {
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: RequestRetryCompletion) {
            completion(true, 2.0) // retry after 2 seconds
    }
}
