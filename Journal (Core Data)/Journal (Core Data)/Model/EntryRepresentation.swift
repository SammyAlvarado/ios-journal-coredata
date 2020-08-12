//
//  EntryRepresentation.swift
//  Journal (Core Data)
//
//  Created by Sammy Alvarado on 8/11/20.
//  Copyright © 2020 Sammy Alvarado. All rights reserved.
//

import Foundation

struct EntryRepresentation: Codable {
    var identifier: String
    var bodyText: String?
    var title: String
    var timestamp: Date
    var mood: String
}


/*
 self.identifier = identifier
 self.bodyText = bodyText
 self.title = title
 self.timestamp = timestamp
 self.mood = mood.rawValue

 identifier: UUID = UUID(),
 bodyText: String,
 title: String,
 timestamp: Date,
 mood: Mood = .😐,

 */
