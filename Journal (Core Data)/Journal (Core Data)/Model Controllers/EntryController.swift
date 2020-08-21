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

    func fetchFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("jason")

        let entry = URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching tasks: \(error)")
                completion(.failure(.otherError))
                return
            }

            guard let data = data else {
                print("No data returned by Data Task")
                completion(.failure(.noData))
                return
            }

            do {
                let entryrepresentations = Array(try JSONDecoder().decode([String: EntryRepresentation].self, from: data).values)
                try self.update(with: entryrepresentations)
                completion(.success(true))
            } catch {
                print("Error decoding task representations: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }
        entry.resume()
    }

    func sendEntryToServer(entry: Entry, completion: @escaping CompletionHandler = {_ in }) {
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

            print("Error encoding task: \(entry), \(error)")
            completion(.failure(.noEncode))
            return
        }

        let entry = URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error PUTting task to server: \(error)")
                completion(.failure(.otherError))
                return
            }

            completion(.success(true))
        }
        entry.resume()
    }

    func deleteEntryFromServer(_ entry: Entry, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = entry.identifier else {
            completion(.failure(.noIdentifier))
            return
        }

        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(.success(true))

        }
        task.resume()
    }

    private func update(with representation: [EntryRepresentation]) throws {
//        let contexts = CoreDataStack.shared.container.newBackgroundContext()

        let identifiersToFetch = representation.compactMap({UUID(uuidString: $0.identifier)})

        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representation))
        var taskToCreate = representationsByID

        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let context = CoreDataStack.shared.mainContext

        context.performAndWait {
            do {
                let existingTasks = try context.fetch(fetchRequest)

                for entry in existingTasks {
                    guard let id  = entry.identifier,
                        let representation = representationsByID[id] else { continue }

                    entry.title = representation.title
                    entry.bodyText = representation.bodyText
                    entry.mood = representation.mood
                    entry.timestamp = representation.timestamp

                    taskToCreate.removeValue(forKey: id)
                }

                for representation in taskToCreate.values {
                    Entry(entryRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching tasks for UUIDs: \(error)")
            }
        }
        try CoreDataStack.shared.save(context:context)

    }

}
