//
//  MaterialRoot.swift
//  widgetExtension
//
//  Created by Matteo Ciannavei on 25/07/23.
//

import Foundation

// MARK: - MaterialRoot
struct MaterialRoot: Codable {
    let talents, weapon, weaponPrimary, common: [GenshinMaterial]
    let currency, elemental, jewels, locals: [GenshinMaterial]
    let experience, ingredient: [GenshinMaterial]
}

// MARK: - Common
struct GenshinMaterial: Codable {
    let key, image: String
    let rarity, position, level: Int
    let type: GenshinMaterialType
    let hasSiblings: Bool
    let days: [Int]
    let recipes, obtainedFrom: [ObtainedFrom]
    let attributes: GenshinMaterialAttributes?
}

// MARK: - Attributes
struct GenshinMaterialAttributes: Codable {
    let canBeObtainedFromAnExpedition: Bool?
    let experience, pricePerUsage, farmingRespawnTime: Int?
}

// MARK: - ObtainedFrom
struct ObtainedFrom: Codable {
    let createsMaterialKey: String
    let needs: [GenshinMaterialNeed]
}

// MARK: - Need
struct GenshinMaterialNeed: Codable {
    let key: String
    let quantity: Int
}

enum GenshinMaterialType: String, Codable {
    case common = "common"
    case currency = "currency"
    case elementalStone = "elementalStone"
    case expCharacter = "expCharacter"
    case expWeapon = "expWeapon"
    case ingredient = "ingredient"
    case jewels = "jewels"
    case local = "local"
    case talents = "talents"
    case weapon = "weapon"
    case weaponPrimary = "weaponPrimary"
}
