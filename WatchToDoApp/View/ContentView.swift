//
//  ContentView.swift
//  WatchToDoApp
//
//  Created by L_0019 on 2024/08/08.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    
    private let watchManager = WatchCommunicationManager()
    @State private var title = ""
    @State private var works: [Work] = []
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Button {
                addWork()
            } label: {
                Label("Add Work", systemImage: "plus")
            }
            
            TextField("タイトル", text: $title)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            List {
                ForEach(works, id: \.self) { work in
                    HStack {
                        Button {
                            updateWork(work: work)
                        } label: {
                            Image(systemName: work.flag ? "checkmark.circle.fill" : "circle")
                        }
                        Text(work.title ?? "none")
                    }
                }
                .onDelete(perform: deleteItems)
                
            }
        }.onAppear {
            fetchWorks()
            watchManager.isUptate.sink { result in
                if result {
                    fetchWorks()
                }
            }.store(in: &cancellables)
        }
    }
    
    private func fetchWorks() {
        works = []
        works = CoreDataRepository.fetch().sorted(by: { $0.id?.uuidString ?? "" > $1.id?.uuidString ?? "" })
        watchManager.sendWorks(works: works)
    }
    
    private func addWork() {
        if title.isEmpty { return }
        let newWork: Work = CoreDataRepository.newEntity()
        // 新しいエンティティにデータを設定
        newWork.id = UUID()
        newWork.title = title
        newWork.timestamp = Date()
        CoreDataRepository.insert(newWork)
        fetchWorks()
        title = ""
    }
    
    private func updateWork(work: Work) {
        guard let id = work.id else { return }
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let work: Work = CoreDataRepository.fetchSingle(predicate: predicate)
        work.flag = !work.flag
        fetchWorks()
    }
    
    private func deleteItems(at offsets: IndexSet) {
        
        offsets.map { works[$0] }.forEach(CoreDataRepository.delete)
        
        fetchWorks()
    }
}

#Preview {
    ContentView()
}
