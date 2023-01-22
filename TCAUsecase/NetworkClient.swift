import Foundation
import ComposableArchitecture

struct NewNetworkClient {
    var load: (_ url: URLRequest) async throws -> (Data, URLResponse)
}

extension NewNetworkClient: DependencyKey {
    static var liveValue: NewNetworkClient {
        .init { url in
            try await URLSession.shared.data(for: url)
        }
    }
    
    static var previewValue: NewNetworkClient {
        .init { url in
            let items = [DisplayItem(id: "Yes", title: "WOW"),
                         DisplayItem(id: "No", title: "WOW 2")]
            
            
            return (try JSONEncoder().encode(items), URLResponse())
        }
    }
}

extension DependencyValues {
    var newNetworkClient: NewNetworkClient {
        get { self[NewNetworkClient.self] }
        set { self[NewNetworkClient.self] = newValue }
    }
}
