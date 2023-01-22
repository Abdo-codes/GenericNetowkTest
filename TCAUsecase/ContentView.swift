import SwiftUI
import ComposableArchitecture


struct DisplayItem: Identifiable, Equatable, Codable {
    let id: String
    let title: String
}

struct ListFeature: ReducerProtocol {
    typealias Network = NetworkFeature<[DisplayItem]>
    struct State: Equatable {
        var displayItems: IdentifiedArrayOf<ItemFeature.State> {
            displayLoadingIndicator ? placeholder : dataSource
        }
        var placeholder: IdentifiedArrayOf<ItemFeature.State> = [
                .init(item: .init(id: "Yes", title: "WOW")),
                .init(item: .init(id: "No", title: "WOW 2"))
        ]
        
        var dataSource: IdentifiedArrayOf<ItemFeature.State> = []
        
        var contentState: Network.ContentState = .initial
        
        var displayLoadingIndicator: Bool {
            contentState.isLoading
        }
        
        var reductionReason: RedactionReasons {
            displayLoadingIndicator ? .placeholder : .init()
        }
        
        var displayError: String?
        var networkState: Network.State {
            get {
                Network.State(contentState: contentState)
            }
            set {
                handleContentChange(contentState: newValue.contentState)
            }
        }
        
        mutating func handleContentChange(contentState: Network.ContentState) {
           
            switch contentState {
            case let .loaded(value, _):
                dataSource.append(contentsOf: value.compactMap { .init(item: $0) })
            case .failed(_):
                displayError = "Error happened!"
            default:
                return
            }
        }
    }
    
    enum Action {
        case initial
        case item(id: DisplayItem.ID, action: ItemFeature.Action)
        case network(Network.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .initial:
                return .task {
                    .network(.load(URLRequest.init(url: .init(string: "www.google.com")!)))
                }
            case .network(_):
                return .none
            }
        }
        Scope(state: \.networkState, action: /Action.network) {
            Network()
        }
    }
}

struct ContentView: View {
    let store: StoreOf<ListFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEachStore(
                    self.store.scope(
                        state: \.displayItems,
                        action: ListFeature.Action.item(id:action:)
                    )
                ) {
                    ItemView(store: $0)
                }
            }
            .redacted(reason: viewStore.reductionReason)
            .onAppear{
                viewStore.send(.initial)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialState: .init(), reducer: ListFeature()))
    }
}
