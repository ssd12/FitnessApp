import Foundation
import RxSwift

class Parser {
    init(_ responseToParse: Any) {
        guard let response = responseToParse as? [String:String] else { return }
        guard let body = response["body"] else { return }
        guard let responseType = response["type"] else { return }
        ObserverService.shared.emitObservable(Utilities.ResponseType(rawValue: responseType) ?? .error, body)
    }
}
