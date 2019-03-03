//
//  YoutubeFetcher.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

public extension String {
    /**
     Convenient method for decoding a html encoded string
     */
    func stringByDecodingURLFormat() -> String {
        let result = self.replacingOccurrences(of: "+", with:" ")
        return result.removingPercentEncoding!
    }

    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    /**
     Parses a query string
     @return key value dictionary with each parameter as an array
     */
    func dictionaryFromQueryStringComponents() -> [String: Any] {
        var parameters = [String: Any]()
        for keyValue in components(separatedBy: "&") {
            let keyValueArray = keyValue.components(separatedBy: "=")
            if keyValueArray.count < 2 {
                continue
            }
            let key = keyValueArray[0].stringByDecodingURLFormat()
            let value = keyValueArray[1].stringByDecodingURLFormat()
            parameters[key] = value as Any?
        }
        return parameters
    }
}

open class Youtube: NSObject {
    static let infoURL = "https://www.youtube.com/get_video_info?video_id="
    static var userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"

    static func loadVideoInfos(youtubeID: String, completionHandler: @escaping ((URL?) -> Void)) {
        let urlString = String(format: "%@%@", infoURL, youtubeID)

        guard let url = URL(string: urlString) else {
            completionHandler(nil)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"

        let session = URLSession(configuration: URLSessionConfiguration.default)

        session.dataTask(with: request, completionHandler: { (data, response, _) -> Void in
            if let data = data as Data?,
                let resultString = String(data: data, encoding: String.Encoding.utf8) {

                let result = resultString.dictionaryFromQueryStringComponents()
                let videoTitle = result["title"] as? String ?? ""

                guard let fmtStreamMap = result["url_encoded_fmt_stream_map"] as? String else {
                    completionHandler(nil)

                    return
                }
                // Live Stream
                if result["live_playback"] != nil {
                    completionHandler(nil)
                } else {
                    let fmtStreamMapArray = fmtStreamMap.components(separatedBy: ",")
                    for videoEncodedString in fmtStreamMapArray {
                        var videoComponents = videoEncodedString.dictionaryFromQueryStringComponents()
                        videoComponents["title"] = videoTitle as Any?
                        videoComponents["isStream"] = false as Any?

                        let url = videoComponents["url"] as? String ?? ""

                        completionHandler(URL(string: url))

                        break;
                    }

                }

            } else {
                completionHandler(nil)
            }
        }).resume()
    }
}
