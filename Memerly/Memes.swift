//
//  Response.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/13/21.
//

import Foundation

struct Memes: Decodable {
	let success : Bool
	let data : [String : [Meme]]

	enum CodingKeys: String, CodingKey {
		case success = "success"
		case data = "data"
	}
}
