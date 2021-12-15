//
//  CustomAPIMeme.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/14/21.
//

import Foundation

struct CustomAPIMeme: Decodable {
	let url : String

	enum CodingKeys: String, CodingKey {
		case url = "url"
	}
}
