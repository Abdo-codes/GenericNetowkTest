import Foundation
import ComposableArchitecture

struct NetworkFeature<Response: Equatable & Decodable>: ReducerProtocol {
    enum LoadError: Error, Equatable {
        case networkError
        case decodeFailed
    }
    
    enum Action: Equatable {
        case load(URLRequest)
        case handleResponse(TaskResult<Data>)
        case decode(Data)
        case cancel
    }
    
    enum ContentState: Equatable {
        case initial
        case loading
        case loaded(value: Response, date: Date)
        case failed(LoadError)
        case cancelled
        case timedOut
        case noInternetConnection
    }
    
    struct State {
        var contentState: ContentState = .initial
    }
    
    @Dependency(\.newNetworkClient) var network
    @Dependency(\.responseDecoder) var decoder
    
    private enum NetworkRequestID {}
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .load(let request):
            state.contentState = .loading
            
            return .task {
                await .handleResponse(
                    TaskResult {
                        let value = try await self.network.load(request)
                        return value.0
                    }
                )
            }
            .cancellable(id: NetworkRequestID.self)
            
        case let .handleResponse(.success(value)):
            return .task {
                .decode(value)
            }
        case .decode(let data):
            do {
                state.contentState = .loaded(value: try decoder.decode(type: Response.self, data: data), date: .init())
            } catch let error {
                print(error)
            }
            return .none
        case .handleResponse(.failure):
            state.contentState = .failed(.networkError)
            return .none
        case .cancel:
            return .cancel(id: NetworkRequestID.self)
        }
    }
}

extension NetworkFeature.ContentState {
    
    var error: NetworkFeature.LoadError? {
        CasePath(Self.failed).extract(from: self)
    }
    
    var isLoading: Bool {
        .loading == self
    }
}
