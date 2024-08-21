//
//  ContentView.swift
//  WatchToDoApp Watch App
//
//  Created by L_0019 on 2024/08/08.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    private let iOSManager = iOSCommunicationManager.shared
    @State var works: [Work] = []
    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            List {
                ForEach(works, id: \.self) { work in
                    WorkRowView(work: work)
                }
            }
        }
        .onAppear {
            works = CoreDataRepository.fetch()
            iOSManager.works.sink { works in
                self.works = []
                self.works = works
            }.store(in: &cancellables)
        }
    }
}

struct WorkRowView: View {
    private let iOSManager = iOSCommunicationManager.shared
    public let work: Work
    @State var isFlag = false
    
    private func updateWork(work: Work) {
        iOSManager.requestToggleFlag(work: work)
    }
    
    var body: some View {
        HStack {
            Button {
                isFlag.toggle()
                updateWork(work: work)
            } label: {
                Image(systemName: isFlag ? "checkmark.circle.fill" : "circle")
            }
            Text(work.title ?? "none")
        }
        .onAppear {
            isFlag = work.flag
        }
    }
}
