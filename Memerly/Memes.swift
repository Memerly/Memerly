//
//  Memes.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/13/21.
//

import Foundation

struct Memes: Decodable {
	let data : [Meme]

	enum CodingKeys: String, CodingKey {
		case data = "data"
	}
}

