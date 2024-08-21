//
//  CommunicationKey.swift
//  WatchToDoApp Watch App
//
//  Created by L_0019 on 2024/08/13.
//

import UIKit

enum CommunicationKey: String {
    /// Works送信
    case I_SEND_WORKS
    
    /// フラグ更新
    case W_REQUEST_UPDATE_FLAG
    
    /// 辞書型の中に存在するキーを返す
    static func checkForKeyValue(_ dic: [String: Any]) -> CommunicationKey? {
        guard let key = dic.keys.first else { return nil }
        switch CommunicationKey(rawValue: key) {
        case .some(let dicKey):
            return dicKey
        case .none:
            return nil
        }
    }
}

