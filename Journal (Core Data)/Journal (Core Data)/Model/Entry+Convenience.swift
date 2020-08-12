//
//  Entry+Convenience.swift
//  Journal (Core Data)
//
//  Created by Sammy Alvarado on 8/5/20.
//  Copyright © 2020 Sammy Alvarado. All rights reserved.
//

import Foundation
import CoreData

enum Mood: String, CaseIterable {
    case 😁
    case 🥺
    case 😐
}

extension Entry {

    var entryRepresentation: EntryRepresentation? {
        guard let title = title,
            let mood = mood else { return nil }

        return EntryRepresentation(identifier: identifier?.uuidString ?? "",
                                   bodyText: bodyText,
                                   title: title,
                                   timestamp: Date(),
                                   mood: mood)
    }

    @discardableResult convenience init(identifier: UUID = UUID(),
                                        bodyText: String?,
                                        title: String,
                                        timestamp: Date,
                                        mood: Mood = .😐,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        self.init(context: context)
        self.identifier = identifier
        self.bodyText = bodyText
        self.title = title
        self.timestamp = timestamp
        self.mood = mood.rawValue
    }

    @discardableResult convenience init?(entryRepresentation: EntryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let mood = Mood(rawValue: entryRepresentation.mood),
            let identifier = UUID(uuidString: entryRepresentation.identifier) else { return nil }

        self.init(identifier: identifier,
                  bodyText: entryRepresentation.bodyText,
                  title: entryRepresentation.title,
                  timestamp: entryRepresentation.timestamp,
                  mood: mood,
                  context: context)
    }
}



