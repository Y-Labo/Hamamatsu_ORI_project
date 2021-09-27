//
//  AmplifyApiClient.swift
//  AmplifyAuthSample
//
//  Created by Shugo Ushio on 2021/09/11.
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore

fileprivate var idToken: String?

struct EntityData: Codable {
    var type: String
    var id: String
    var datetime: DatetimeAttribute
    var minorBeaconId: StringAttribute
    var majorBeaconId: StringAttribute
    var rssi: StringAttribute
    
    struct StringAttribute: Codable {
        var type: String = "Text"
        var value: String
    }

    struct DatetimeAttribute: Codable {
        var type: String = "DateTime"
        var value: Date
    }
}

open class ApiClient: NSObject {
    
    private static let apiName: String = "orion"
    private static let serviceName: String = "shizuoka_university"
    private static let typeName: String = "BeaconData"
    
    public static func postData(deviceId: String, time: Date, minorBeaconId: String, majorBeaconId: String, rssi: Double) throws {
        let headers = [
            "Fiware-Service": ApiClient.serviceName,
            "Fiware-Service-Path": "/beacon/\(deviceId)",
            "Content-Type": "application/json"
        ]
        
        let body: EntityData = EntityData(
            type: ApiClient.typeName,
            id: "urn:ngsi-ld:\(typeName):\(UUID().uuidString)",
            datetime: EntityData.DatetimeAttribute(value: time),
            minorBeaconId: EntityData.StringAttribute(value: minorBeaconId),
            majorBeaconId: EntityData.StringAttribute(value: majorBeaconId),
            rssi: EntityData.StringAttribute(value: "\(rssi)")
        )
        
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let d = try encoder.encode(body)
        let request = RESTRequest(apiName: ApiClient.apiName, path: "/v2/entities", headers: headers, body: Data(d))
        
        Amplify.API.post(request: request) { result in
            switch result {
            case .success(let data):
                let str = String(decoding: data, as: UTF8.self)
                print("Success \(str)")
            case .failure(let apiError):
                
                print("Failed", apiError)
            }
        }
        
    }

    public static func getOrionVersion() {
        let request = RESTRequest(apiName: ApiClient.apiName, path:"/version")
        
        Amplify.API.get(request: request) { result in
            switch result {
            case .success(let data):
                let str = String(decoding: data, as: UTF8.self)
                print("Success \(str)")
            case .failure(let apiError):
                
                print("Failed", apiError)
            }
        }
    }
    
    public static func signInIfNot(username: String, password: String) {
        Amplify.Auth.fetchAuthSession { result in
            
            switch result {
            case .success:
                print("Has session")
                do {
                    let session = try result.get()
                    if (!session.isSignedIn) {
                        signIn(username: username, password: password)
                    } else {
                        if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                            let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                            idToken = tokens.idToken
                            print("id token set: \(idToken!)")
                        }
                    }
                } catch {
                    print("Fetch auth session failed with error - \(error)")
                    signIn(username: username, password: password)
                }
            case .failure:
                signIn(username: username, password: password)
            }
        }
    }

    public static func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
                do {
                    let session = try result.get()
                    if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                        let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                        idToken = tokens.idToken
                        print("id token set: \(idToken!)")
                    }
                } catch {
                    print("Sign in failed with error - \(error)")
                }
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
}
