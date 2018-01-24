import Alamofire
import Foundation
import ObjectMapper

public class Client {
    public static let sharedClient = Client()

    public var consumerKey: String?
    public var consumerSecret: String?
    public var siteURL: String?

    init() {}

    init(siteURL: String, consumerKey: String, consumerSecret: String) {
        self.siteURL = siteURL
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }

    public func get<T: Mappable>(type: String, id: Int, completion: @escaping (_ success: Bool, _ value: T?) -> Void) {
        let baseURL = URL(string: siteURL!)
        let requestURL = URL(fileURLWithPath: "wc-api/v3/\(type)s/\(id)", relativeTo: baseURL)
        let requestURLString = requestURL.absoluteString

        guard let user = consumerKey, let password = consumerSecret else {
            completion(false, nil)
            return
        }
        Alamofire.request(requestURL)
            .authenticate(user: user, password: password)
            .responseJSON { response in
                if response.result.isSuccess {
                   
                   let JSON = response.result.value as! [[String : Any]]!
                    let object = Mapper<T>().map(JSON: JSON![0][type]! as! [String : Any])!
                    
                //TODO fix there
                    completion(true, object)
                } else {
                    completion(false, nil)
                }
        }
    }

    public func getArray<T: Mappable>(type: RequestType, slug: String, limit: Int = 10, completion: @escaping (_ success: Bool, _ value: [T]?) -> Void) {
        guard let url = siteURL, let user = consumerKey, let password = consumerSecret else {
            completion(false, nil)
            return
        }

        let baseURL = URL(string: url)
        let requestURL = URL(string: "wc-api/v3/\(slug)?filter[limit]=\(limit)", relativeTo: baseURL )
        let requestURLString = requestURL!.absoluteString

        Alamofire.request(requestURLString)
            .authenticate(user: user, password: password)
            .responseJSON { response in
                if response.result.isSuccess {

                        let JSON = response.result.value as! [[String : Any]]!
                    let objects = Mapper<T>().mapArray(JSONString: JSON![0][type.rawValue]! as! String)
                        
                
                    

                        completion(true, objects)
                } else {
                    completion(false, nil)
                }
        }
    }
}

