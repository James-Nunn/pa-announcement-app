//
//  Recipients.swift
//  IA3V2
//
//  Created by James Nunn on 5/6/2023.
//

import Foundation
import CoreData

extension Drafts {
    var recipientsArray: [String] {
        return self.recipients?.compactMap {($0 as? Recipients)?.name} ?? []
    }
}
