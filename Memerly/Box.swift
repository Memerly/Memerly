//
//  Box.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/13/21.
//

import Foundation

struct Box: Decodable {
	let text : String

	enum CodingKeys : String, CodingKey {
		case text = "text"
	}
}
