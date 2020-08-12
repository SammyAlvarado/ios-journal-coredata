//
//  EntryController.swift
//  Journal (Core Data)
//
//  Created by Sammy Alvarado on 8/11/20.
//  Copyright © 2020 Sammy Alvarado. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

let baseURL = URL(string: "https://journal-core-data-day3.firebaseio.com/")!

class EntryController {

    init() {

    }

    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void

    func sendTaskToServer(entry: Entry, completion: @escaping CompletionHandler = {_ in }) {
        guard let uuid = entry.identifier else {
            completion(.failure(.noIdentifier))
            return
        }

        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"

        do {
            guard let representation = entry.entryRepresentation else {
                completion(.failure(.noRep))
                return
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error ")
        }
    }
}
