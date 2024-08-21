//
//  Work+CoreDataClass.swift
//  WatchToDoApp
//
//  Created by L_0019 on 2024/08/13.
//
//

import Foundation
import CoreData

@objc(Work)
public class Work: NSManagedObject, Encodable, Decodable {
    
    enum CodingKeys: CodingKey {
        case id, title, timestamp, flag
    }
    
    convenience init(id: UUID, title: String, timestamp: Date, flag: Bool) {
        self.init()
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.flag = flag
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(flag, forKey: .flag)
    }
    
    required public convenience init(from decoder: Decoder) throws {
        // CoreDataをJSONにデコードするにはuserInfoからcontextを取得する
        guard let context = decoder.userInfo[CodingUserInfoKey(rawValue: "managedObjectContext")!] as? NSManagedObjectContext else { fatalError() }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.flag = try container.decode(Bool.self, forKey: .flag)
    }
}
