//
//  HomeViewModel.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-20.
//

import Foundation
import RealmSwift

class HomeViewModel {
    static let shared = HomeViewModel()
    
    var events = [Event]()
    var users = [User]()
    var ad = [Ad]()
    var header = [Header]()
    var startDate:Date = Double.todayAtMidnightTimestamp() // Start with today at midnight
    
    var items:[HomeCellViewModel] = []
    
    var organisations :[HomeCellViewModel] = [
        HomeMessageViewModel(message: "我們旨在幫助香港移民融入加拿大社區。如果您的機構也有類似的使命，立即點擊加入，讓更多的香港人能夠輕鬆找到您的服務，並參與您的活動。",urlString: "https://docs.google.com/forms/d/e/1FAIpQLSdcI1mvxgnLhBomwpI38sMiFDH5r2b1x5xN2SrRZJ2anTm8zw/viewform?usp=sf_link")
    ]
    
    var mentors:[HomeCellViewModel] = [
    HomeMessageViewModel(message: "幫助新移民適應加拿大的生活，現在就點擊加入我們的導師計劃，為他們提供有價值的經驗和知識！",urlString: "https://docs.google.com/forms/d/e/1FAIpQLSe43oaR1w01y6mhiQvS5BhItAHLWopWW7hCvm_G66a2gSJiUg/viewform?usp=sf_link")
    ]
    
    func getItemsFor(categoryType:HomeCategoryType) -> [HomeCellViewModel]{
        switch categoryType {
        case .grouped:
           return  items.compactMap({
                switch $0 {
                case let vm as EventCellViewModel:
                    if vm.eventStatus == .confirmed {
                        return $0
                    }else {
                        return nil
                    }
                default:
                    return $0
                }
            })
        case .grouping:
           return  items.compactMap({
                switch $0 {
                case let vm as EventCellViewModel:
                    if vm.eventStatus == .grouping {
                        return $0
                    }else {
                        return nil
                    }
                default:
                    return $0
                }
            })
        case .organisation:
            return organisations
        case .mentor:
            return mentors
        default:
            break
        }
        
        return []
    }
    
    func fetchInitialData(perPage: Int,completion:@escaping ([Event]) -> Void) {
        DatabaseManager.shared.fetchEvents(numberOfResults: perPage) { [weak self] events in
            guard let events = events,let newDate = events.last?.endDate else {
                completion([])
                self?.createViewModels()
                return}
            self?.startDate = Date(timeIntervalSince1970: newDate.adding(days: 1).startOfDayTimestampUTC())
            self?.events = events.sorted(by: { $0.startDateTimestamp < $1.startDateTimestamp
            })
            
            self?.createViewModels()
            completion(events)
        }
    }
    
    func fetchMoreData(perPage: Int,completion:@escaping ([Event]) -> Void) {
        
        DatabaseManager.shared.fetchEvents(numberOfResults: perPage, startDate:startDate) { [weak self] events in
            guard let events = events, let newDate = events.last?.endDate else {
                completion([])
                return}
            self?.startDate = Date(timeIntervalSince1970: newDate.adding(days: 1).startOfDayTimestampUTC())
            self?.insertViewModels(with: events.sorted(by: { $0.startDateTimestamp < $1.startDateTimestamp
            }))
            completion(events)
        }
    }
    
    public func fetchOrganisations(completion:@escaping () -> Void){
        
        // MARK: - stop fetching if organisations exist
        if self.organisations.count > 1 {
            completion()
            return
        }
        DatabaseManager.shared.fetchOrganisations { organisations in
            let VMs:[HomeCellViewModel] = organisations.compactMap({
                OrganisationViewModel(organisation: $0)
            })
            self.organisations.append(contentsOf: VMs)
            completion()
        }
        
    }
    
    public func fetchMentors(completion:@escaping () -> Void) {
        if self.mentors.count > 1 {
            completion()
            return
        }
        DatabaseManager.shared.fetchMentors { mentors in
            let VMs:[HomeCellViewModel] = mentors.compactMap({
                MentorViewModel(mentor: $0)
            })
            self.mentors.append(contentsOf: VMs)
            completion()
            
        }
        
    }
    
    private func insertViewModels(with events:[Event]) {
        var newVM:[HomeCellViewModel] = sortEvents(for: events)
        
        var adArray = [Int]()
        if events.count > 4 {
            for i in 1...events.count/4 {
                adArray.append(i*4)
            }
            
        }
        
        
        // MARK: - add ad
//        adArray.forEach({
//            guard newVM.count > 4 else {return}
//            let ad = AdViewModel(ad: Ad(id: UUID().uuidString))
//            newVM.insert(ad, at: $0)
//        })
        
        items.append(contentsOf: newVM)
        
    }
    
    private func createViewModels(){
        items = sortEvents(for: events)
        
        
        // MARK: - add ad
//        for (index,_) in items.enumerated() {
//            if index % 4 == 3 {
//                let ad = Ad(id: UUID().uuidString)
//                items.insert(AdViewModel(ad: ad), at: index)
//            }
//        }
        
    }
    
    private func sortEvents(for events:[Event]) -> ([HomeCellViewModel]) {
        
        let realm = try! Realm()
        
        
        let blockedusers:BlockedUsers = realm.objects(BlockedUsers.self).first ?? .init()
        
        
        
        
        
        return events.sorted(by: {$0.startDate < $1.startDate}).compactMap({
            
            if let username = $0.organisers.first?.username {
                if blockedusers.blockedUserList.contains(username) {
                    return nil
                }
            }
        
            
            if $0.endDate < Date() {
                
                return nil
            }else {
                
                
                return EventCellViewModel(event: $0)
            }
        })
        
    }
    
}

