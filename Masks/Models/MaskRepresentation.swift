//
//  MaskRepresentation.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

struct MaskRepresentation: Codable, Equatable {
    var name: String
    var notes: String?
    var priority: String
    var identifier: String
}
