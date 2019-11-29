//
// HCVimeoVideoExtractor.swift
// HCVimeoVideoExtractor
//
// Created by Mo Cariaga on 13/02/2018.
// Copyright (c) 2018 Mo Cariaga <hermoso.cariaga@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Cocoa

final class HCVimeoVideoExtractor: NSObject {
    fileprivate let domain = "ph.hercsoft.HCVimeoVideoExtractor"

    public static func fetchVideoURLFrom(id: String, completionHandler: @escaping ((URL?) -> Void)) {
        let configURL = "https://player.vimeo.com/video/{id}/config"

        guard let dataURL = URL(string: configURL.replacingOccurrences(of: "{id}", with: id)) else {
            completionHandler(nil)
            return
        }

        var request = URLRequest(url: dataURL)
        request.timeoutInterval = 5.0
        request.httpMethod = "GET"

        let session = URLSession.shared


        session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                
            guard error == nil else {
                completionHandler(nil)
                return
            }

            guard let responseData = data else {
                completionHandler(nil)
                return
            }

            do {
                guard let data = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    completionHandler(nil)
                    return
                }

                if let files = (data as NSDictionary).value(forKeyPath: "request.files.progressive") as? Array<Dictionary<String, Any>> {

                    let video = HCVimeoVideo()
                    if let title = (data as NSDictionary).value(forKeyPath: "video.title") as? String {
                        video.title = title
                    }

                    for file in files {
                        if let quality = file["quality"] as? String {
                            if let url = file["url"] as? String {
                                video.videoURL[HCVimeoVideoExtractor.videoQualityWith(string: quality)] = URL(string: url)
                            }
                        }
                    }

                    if video.videoURL.count > 0 {
                        let url = video.videoURL.first?.value
                        completionHandler(url)
                    }
                    else {
                        completionHandler(nil)
                    }
                }
                else {
                    completionHandler(nil)
                }
            } catch {
                completionHandler(nil)
            }
        }).resume()

    }
 
    public static func videoQualityWith(string: String) -> HCVimeoVideoQuality {
        if string == "360p" {
            return .Quality360p
        }
        else if string == "540p" {
            return .Quality540p
        }
        else if string == "640p" {
            return .Quality640p
        }
        else if string == "720p" {
            return .Quality720p
        }
        else if string == "960p" {
            return .Quality960p
        }
        else if string == "1080p" {
            return .Quality1080p
        }
        
        return .QualityUnknown
    }
    
    public static func thumbnailQualityWith(string: String) -> HCVimeoThumbnailQuality {
        if string == "640" {
            return .Quality640
        }
        else if string == "960" {
            return .Quality960
        }
        else if string == "1280" {
            return .Quality1280
        }
        else if string == "base" {
            return .QualityBase
        }        
        return .QualityUnknown
    }
}

public enum HCVimeoThumbnailQuality: String {
    case Quality640 = "640"
    case Quality960 = "960"
    case Quality1280 = "1280"
    case QualityBase = "base"
    case QualityUnknown = "unknown"
}

public enum HCVimeoVideoQuality: String {
    case Quality360p = "360p"
    case Quality540p = "540p"
    case Quality640p = "640p"
    case Quality720p = "720p"
    case Quality960p = "960p"
    case Quality1080p = "1080p"
    case QualityUnknown = "unknown"
}

final class HCVimeoVideo: NSObject {
    public var title = ""
    public var thumbnailURL = [HCVimeoThumbnailQuality: URL]()
    public var videoURL = [HCVimeoVideoQuality: URL]()
}
