//
//  iOSCommunicationManager.swift
//  WatchToDoApp Watch App
//
//  Created by L_0019 on 2024/08/08.
//

import Combine
import WatchConnectivity

class iOSCommunicationManager: NSObject {
    
    static let shared = iOSCommunicationManager()
    
    // iOSと通信可能かどうか
    public var isReachable: AnyPublisher<Bool, Never> {
        _isReachable.eraseToAnyPublisher()
    }
    private var _isReachable = CurrentValueSubject<Bool, Never>(false)
    
    public var works: AnyPublisher<[Work], Never> {
        _works.eraseToAnyPublisher()
    }
    private let _works = PassthroughSubject<[Work], Never>()
    
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
    
    /// フラグ更新
    public func requestToggleFlag(work: Work) {
        let requestDic: [String: String] = [CommunicationKey.W_REQUEST_UPDATE_FLAG.rawValue: work.id?.uuidString ?? ""]
        self.session.sendMessage(requestDic, replyHandler: { _ in })
    }
}


extension iOSCommunicationManager: WCSessionDelegate {
    /// セッションのアクティベート状態が変化した際に呼ばれる
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("セッション：アクティベート\(session.activationState)")
            _isReachable.send(session.isReachable)
        }
    }
    
    /// iOSアプリ通信可能状態が変化した際に呼ばれる
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("通信状態が変化：\(session.isReachable)")
        _isReachable.send(session.isReachable)
    }
    
    /// sendMessageメソッドで送信されたデータを受け取るデリゲートメソッド(使用されていない)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        sendWorks(message)
    }
    
    /// transferUserInfoメソッドで送信されたデータを受け取るデリゲートメソッド(バックグラウンドでもキューとして残る)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        sendWorks(userInfo)
    }
    
    private func sendWorks(_ dic: [String : Any]) {
        print("データ受信：\(dic)")
                

        guard let key = CommunicationKey.checkForKeyValue(dic),
              key == CommunicationKey.I_SEND_WORKS else { return }
        
        // iOSからデータを取得
        guard let json = dic[key.rawValue] as? String else { return }
        // JSONデータをString型→Data型に変換
        guard let jsonData = String(json).data(using: .utf8) else { return }
        DispatchQueue.main.async {
            // 保存前にデータを全て削除
            CoreDataRepository.deleteAllData()
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey(rawValue: "managedObjectContext")!] = CoreDataRepository.context
            // JSONデータを構造体に準拠した形式に変換
            if let works = try? decoder.decode([Work].self, from: jsonData) {
                // この時点で保存される
                CoreDataRepository.saveContext()
                self._works.send(works)
            }
        }
    }
}
