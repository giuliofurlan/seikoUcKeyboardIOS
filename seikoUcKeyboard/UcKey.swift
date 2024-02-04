//
//  UcKey.swift
//  seikoUcKeyboard
//
//  Created by Giulio Furlan on 03/02/24.
//

import Foundation

struct UcKey: Identifiable, Hashable {
    let id = UUID()
    let value: Int?
    let text: String
    let size: Int = 1
}
