//
//  CommunicationJsonConverter.swift
//  WatchToDoApp
//
//  Created by L_0019 on 2024/08/13.
//

import UIKit

class CommunicationJsonConverter {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    public func decode(_ json: String) -> [Work]? {
        guard let jsonData = String(json).data(using: .utf8) else { return nil }
        // 使用しているコンテキストを格納する
        decoder.userInfo[CodingUserInfoKey(rawValue: "managedObjectContext")!] = CoreDataRepository.context
        guard let companys = try? decoder.decode([Work].self, from: jsonData) else { return nil }
        return companys
    }
    
    public func convertJson(_ data: [Work]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(data) else { return nil }
        guard let json = String(data: jsonData , encoding: .utf8) else { return nil }
        return json
    }
}

