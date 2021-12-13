//
//  APIMeme.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/13/21.
//

import Foundation

struct APIMemes: Decodable {
	let success : Bool
	let data : APIMeme

	enum CodingKeys: String, CodingKey {
		case success = "success"
		case data = "data"
	}
}
