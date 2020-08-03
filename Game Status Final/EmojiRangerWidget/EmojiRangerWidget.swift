/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A widget that shows the avatar for a single character.
*/

import WidgetKit
import SwiftUI

// 12. TimelineProvider 改成 IntentTimelineProvider
//Provider = 生成 TimelineEntry 設定日期時間與屬性 告诉 WidgetKit update UI 的時間
struct Provider: IntentTimelineProvider {
    typealias Intent = DynamicCharacterSelectionIntent
    
    public typealias Entry = SimpleEntry
    
    func character(for configuration: DynamicCharacterSelectionIntent) -> CharacterDetail {
        let name = configuration.hero?.identifier
        
        // 21. Dynamic configuration >>>> name = configuration.hero?.identifier 可以讓選擇更多在選擇 small size 時更多選項
        
        return CharacterDetail.characterFromName(name: name)
    }

    // 13. TimelineProvider 改成 IntentTimelineProvider 後多了 for configuration: DynamicCharacterSelectionIntent 這個 parameter
    public func snapshot(for configuration: DynamicCharacterSelectionIntent, with context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), relevance: nil, character: .panda)
        
        completion(entry)
        // 2. 設定 snapshot （ 新增 widget 時的 snapshot)
    }

    public func timeline(for configuration: DynamicCharacterSelectionIntent, with context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // 14. 可以利用 configuration 更換 hero 角色
        let selectedCharacter = character(for: configuration) // 7. 選中顯示的 character
        let endDate = selectedCharacter.fullHealthDate
        // 8. 更新的時間
        let oneMinute: TimeInterval = 60
        var currentDate = Date()
        var entries: [SimpleEntry] = []
        
        while currentDate < endDate {
            let relevance = TimelineEntryRelevance(score: Float(selectedCharacter.healthLevel))
            let entry = SimpleEntry(date: currentDate, relevance: relevance, character: selectedCharacter)
            
            currentDate += oneMinute
            entries.append(entry)
            // 9. 每一分鐘加的一個 Entry
        }
        
        // 10. 把 entries 加進 timeline
        let timeline = Timeline(entries: entries, policy: .atEnd)
        //3. 解釋: .atEnd, aftrer, never
        
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    let relevance: TimelineEntryRelevance? //
    let character: CharacterDetail
}

struct PlaceholderView: View {
    var body: some View {
        EmojiRangerWidgetEntryView(entry: SimpleEntry(date: Date(), relevance: nil, character: .panda))
    }
}

struct EmojiRangerWidgetEntryView: View {
    var entry: Provider.Entry
    // 1. Entry 從 timeline provider 來的, 是 widget 的 core engine, 當 widget 想要使用 entry 時, timeline 提供 snapshot (用來提供畫面上的樣子）
    
    @Environment(\.widgetFamily) var family
    @ViewBuilder
    var body: some View {
        switch family {
        //5. switch family 成不同的 view
        case .systemSmall:
            ZStack {
                AvatarView(entry.character)
                    .widgetURL(entry.character.url)
                    // 15. 可以利用 entry.character.url 到指定的 hero 頁面 (換角色+點選跳轉不同頁面)
                    .foregroundColor(.white)
            }
            .background(Color.gameBackground)
        default:
            ZStack {
                HStack(alignment: .top) {
                    AvatarView(entry.character)
                        .foregroundColor(.white)
                    Text(entry.character.bio)
                        .padding()
                        .foregroundColor(.white)
                }
                .padding()
                .widgetURL(entry.character.url)
            }
            .background(Color.gameBackground)
        }
    }
}

struct EmojiRangerWidget: Widget {
    private let kind: String = "EmojiRangerWidget"
    // Kind = Widget identifier string

    public var body: some WidgetConfiguration {
        // 11. CharacterSelection hero enum
        // 長按換角色的功能：StaticConfiguration 改成 IntentConfiguration 才可以互動
        IntentConfiguration(kind: kind, intent: DynamicCharacterSelectionIntent.self, provider: Provider(), placeholder: PlaceholderView()) { entry in
            EmojiRangerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ranger Detail")
        .description("See your favorite ranger.")
        .supportedFamilies([.systemSmall, .systemMedium])
        //4. family weight 中小的大小
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmojiRangerWidgetEntryView(entry: SimpleEntry(date: Date(), relevance: nil, character: .panda))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            // 6. PreviewProvider: 放 placeholder 的地方
        }
    }
}
