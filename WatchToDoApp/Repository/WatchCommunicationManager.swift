//
//  WatchCommunicationManager.swift
//  WatchToDoApp
//
//  Created by L_0019 on 2024/08/08.
//

import UIKit
import Combine
import WatchConnectivity

class WatchCommunicationManager: NSObject {
    
    static let shared = WatchCommunicationManager()
        
    // watchOSと通信可能かどうか
    public var isReachable: AnyPublisher<Bool, Never> {
        _isReachable.eraseToAnyPublisher()
    }
    private var _isReachable = CurrentValueSubject<Bool, Never>(false)
    
    /// 更新されたかどうか
    public var isUptate: AnyPublisher<Bool, Never> {
        _isUptate.eraseToAnyPublisher()
    }
    private var _isUptate = CurrentValueSubject<Bool, Never>(false)
    
    
    // MARK: - Utility
    private let jsonConverter = CommunicationJsonConverter()
    
    private var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }
}

extension WatchCommunicationManager {
    
     /// Work送信
     public func sendWorks(works: [Work]) {
         guard let json = jsonConverter.convertJson(works) else { return }
         let requestDic: [String: String] = [CommunicationKey.I_SEND_WORKS.rawValue: json]
         self.session.sendMessage(requestDic, replyHandler: { _ in })
     }
    
    private func receiveMessage(_ dic: [String : Any]) {
        print("データ受信：\(dic)")
                
        guard let key = CommunicationKey.checkForKeyValue(dic),
              key == CommunicationKey.W_REQUEST_UPDATE_FLAG else { return }
        
        guard let id = dic[key.rawValue] as? String else { return }
       
        DispatchQueue.main.async {
            
            let predicate = NSPredicate(format: "id == %@", id as CVarArg)
            let work: Work = CoreDataRepository.fetchSingle(predicate: predicate)
            work.flag = !work.flag
            CoreDataRepository.saveContext()
            self._isUptate.send(true)
        }
    }
}


extension WatchCommunicationManager: WCSessionDelegate {
    
    /// セッションのアクティベート状態が変化した際に呼ばれる
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watchエラー：\(error.localizedDescription)")
        } else {
            print("Watchセッション：アクティベート\(session.activationState)")
            print("Watch通信状態変化：\(session.isReachable)")
            _isReachable.send(session.isReachable)
        }
    }
    
    /// Watchアプリ通信可能状態が変化した際に呼ばれる
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch通信状態変化：\(session.isReachable)")
        _isReachable.send(session.isReachable)
    }
    
    /// `sendMessage`メソッドで送信されたデータを受け取るデリゲートメソッド
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler(message) // 受信したことを送信側に知らせる

        receiveMessage(message)
    }
    
    /// セッションが非アクティブになった際に呼ばれる
    func sessionDidBecomeInactive(_ session: WCSession) { }

    /// セッションが無効になった際に呼ばれる
    func sessionDidDeactivate(_ session: WCSession) { }
}
