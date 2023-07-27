//
//  GenshinRepository.swift
//  widgetExtension
//
//  Created by Matteo Ciannavei on 25/07/23.
//

import UIKit
import Combine

class GenshinRepository {
    
    var appGroupId: String?
    
    init() {
        if let appGroupId = Bundle.main.infoDictionary?["APP_GROUP_IDENTIFIER"] as? String {
            self.appGroupId = appGroupId
        }
    }
    
    func getTodayMaterials(date: Date) -> ([DisplayMaterial], [DisplayMaterial]) {
        if let appGroupId = self.appGroupId {
            let calendar = Calendar.current
            let dayOfWeek = convertToShioriWeekday(calendar.component(.weekday, from: date))
            
            let todayMaterials = loadJson()
            
            let todayTalents = todayMaterials.talents.filter { material in material.days.contains(dayOfWeek) && material.rarity == 2}
            let todayWeapons = todayMaterials.weaponPrimary.filter { material in material.days.contains(dayOfWeek) && material.rarity == 2}
            
            let displayTalents = todayTalents.map { material in DisplayMaterial(name: material.key,
                                                                                image: talentMaterialImage(imageName: material.image)) }
            let displayWeapons = todayWeapons.map { material in DisplayMaterial(name: material.key,
                                                                                  image: weaponMaterialImage(imageName: material.image)) }
            
            return (displayTalents, displayWeapons)
        }
        return ([], [])
    }
    
    private func weaponMaterialImage(imageName: String) -> UIImage {
        guard let appGroupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId!) else {
            fatalError("Unable to load from App Group.")
        }
        let url = appGroupContainerURL
            .appendingPathComponent("shiori_assets")
            .appendingPathComponent("items")
            .appendingPathComponent("weapon_primary")
        let imageData = try! Data(contentsOf: url.appendingPathComponent(imageName))
        return UIImage(data: imageData)!
    }
    
    private func talentMaterialImage(imageName: String) -> UIImage {
        guard let appGroupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId!) else {
            fatalError("Unable to load from App Group.")
        }
        let url = appGroupContainerURL
            .appendingPathComponent("shiori_assets")
            .appendingPathComponent("items")
            .appendingPathComponent("talents")
        let imageData = try! Data(contentsOf: url.appendingPathComponent(imageName))
        return UIImage(data: imageData)!
    }
    
    private func loadJson() -> MaterialRoot {
        guard let appGroupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId!) else {
            fatalError("Unable to load from App Group.")
        }
        let url = appGroupContainerURL
            .appendingPathComponent("shiori_assets")
            .appendingPathComponent("db")
            .appendingPathComponent("materials.json")
        
        do {
            let jsonData = try Data(contentsOf: url)
            return try JSONDecoder().decode(MaterialRoot.self, from: jsonData)
        } catch {
            fatalError("Unable to decode JSON.")
        }
    }

    // Days start with 1 (Monday) and end with 7 (Sunday).
    private func convertToShioriWeekday(_ weekday: Int) -> Int {
        var customWeekday = weekday - 1
        if customWeekday == 0 {
            customWeekday = 7
        }
        return customWeekday
    }
}
