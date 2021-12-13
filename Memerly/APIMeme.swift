//
//  APIMeme.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/13/21.
//

import Foundation

struct APIMeme: Decodable {
	let page_url : String
	let url : String

	enum CodingKeys: String, CodingKey {
		case page_url = "page_url"
		case url = "url"
	}
}
