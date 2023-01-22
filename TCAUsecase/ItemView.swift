import SwiftUI
import ComposableArchitecture

struct ItemFeature: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let item: DisplayItem
        
        var id: String {
            item.id
        }
    }
    enum Action {}
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        return .none
    }
}

struct ItemView: View {
    let store: StoreOf<ItemFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Text(viewStore.item.title)
        }
    }
}
