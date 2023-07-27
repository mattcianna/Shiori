//
//  widget.swift
//  widget
//
//  Created by Matteo Ciannavei on 25/07/23.
//

import WidgetKit
import SwiftUI

func mockedEntity(widgetFamily: WidgetFamily) -> ShioriWidgetEntry {
    let talentImages = [
        UIImage(named: "teachings-of-admonition.webp")!,
        UIImage(named: "teachings-of-ballad.webp")!,
        UIImage(named: "teachings-of-diligence.webp")!,
        UIImage(named: "teachings-of-elegance.webp")!,
    ]
    let weaponImages = [
        UIImage(named: "boreal-wolfs-milk-tooth.webp")!,
        UIImage(named: "debris-of-decarabians-city.webp")!,
        UIImage(named: "fetters-of-the-dandelion-gladiator.webp")!,
        UIImage(named: "grain-of-aerosiderite.webp")!,
    ]
    return ShioriWidgetEntry(
        date: Date(),
        talents: talentImages.map { image in DisplayMaterial(name: UUID().uuidString, image: image) },
        weapons: weaponImages.map { image in DisplayMaterial(name: UUID().uuidString, image: image) },
        widgetFamily: widgetFamily
    )
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> ShioriWidgetEntry {
        mockedEntity(widgetFamily: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (ShioriWidgetEntry) -> ()) {
        let entry = mockedEntity(widgetFamily: context.family)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ShioriWidgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entryMaterials = GenshinRepository().getTodayMaterials(date: entryDate)
            let entry = ShioriWidgetEntry(date: entryDate, talents: entryMaterials.0, weapons: entryMaterials.1, widgetFamily: context.family)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ShioriWidgetEntry: TimelineEntry {
    let date: Date
    let talents: [DisplayMaterial]
    let weapons: [DisplayMaterial]
    let widgetFamily: WidgetFamily
    
    var materials: [DisplayMaterial] {
        get {
            return talents + weapons
        }
    }
}

struct ShioriWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HStack {
            if (entry.widgetFamily != WidgetFamily.systemSmall) {
                Spacer()
                VStack {
                    Text(formatWeekday())
                        .font(Font.subheadline)
                    Text(formatDay())
                        .font(Font.largeTitle)
                }
                Spacer()
            }
            VStack {
                if (entry.widgetFamily == WidgetFamily.systemSmall) {
                    Spacer()
                    VStack {
                        Text(formatWeekday())
                            .font(Font.subheadline)
                        Text(formatDay())
                            .font(Font.largeTitle)
                    }
                }
                Grid {
                    GridRow {
                        ForEach(entry.weapons, id: \.name) { weapon in
                            Image(uiImage: weapon.image)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .aspectRatio(contentMode: ContentMode.fit)
                        }
                    }
                    GridRow {
                        ForEach(entry.talents, id: \.name) { talent in
                            Image(uiImage: talent.image)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .aspectRatio(contentMode: ContentMode.fit)
                        }
                    }
                }
                .frame(
                    height: 40
                )
                if (entry.widgetFamily == WidgetFamily.systemSmall) {
                    Spacer()
                }
            }
            if (entry.widgetFamily != WidgetFamily.systemSmall) {
                Spacer()
            }
        }
    }
    
    func formatDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd"
        let dayString = dateFormatter.string(from: entry.date)
        return dayString
    }
    
    func formatWeekday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.string(from: entry.date)
        return dayOfWeekString
    }
}

struct ShioriWidget: Widget {
    
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ShioriWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct widget_Previews: PreviewProvider {
    static var previews: some View {
        ShioriWidgetEntryView(entry: mockedEntity(widgetFamily: .systemMedium))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        ShioriWidgetEntryView(entry: mockedEntity(widgetFamily: .systemSmall))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
