//
//  Meme.swift
//  Memerly
//
//  Created by Jarod Wellinghoff on 12/13/21.
//

import Foundation
import Alamofire

struct Meme: Decodable {
	let box_count : Int
	let height : Int
	let id : String
	let name : String
	let url : String
	let width : Int

	init() {
		box_count = 0
		height = 0
		id = ""
		name = ""
		url = ""
		width = 0
	}

	enum CodingKeys: String, CodingKey {
		case box_count = "box_count"
		case height = "height"
		case id = "id"
		case name = "name"
		case url = "url"
		case width = "width"
	}
}

//extension Meme: Displayable {
//	var boxCount: Int {
//		box_count
//	}
//}
