import Foundation
import ComposableArchitecture

struct ResponseDecoder {
    var decoder: JSONDecoder
    
    func decode<T: Decodable>(type: T.Type, data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}

extension DependencyValues {
    var responseDecoder: ResponseDecoder {
        get { self[ResponseDecoder.self] }
        set { self[ResponseDecoder.self] = newValue }
    }
}

extension ResponseDecoder: DependencyKey {
    static var liveValue: ResponseDecoder {
        Self(decoder: .init())
    }
}
