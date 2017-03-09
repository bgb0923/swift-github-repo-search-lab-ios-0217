//
//  GithubAPIClient.swift
//  github-repo-starring-swift
//
//  Created by Haaris Muneer on 6/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Alamofire

class GithubAPIClient {
    
    class func getRepositories(with completion: @escaping ([[String : Any]]) -> Void) {
        let urlString = "https://api.github.com/repositories?client_id=\(Github.ID)&client_secret=\(Github.secret)"
        if let url = URL(string: urlString) {
            let session = URLSession.shared
            let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error)  in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] ?? [[:]]
                        completion(json)
                    } catch {
                        
                    }
                }
            })
            dataTask.resume()
        }
    }
    
    class func checkIfRepositoryIsStarred(_ repoName: String, completion: @escaping (Bool) -> Void) {
        let baseURL = "https://api.github.com/user/starred/\(repoName)"
        if let url = URL(string: baseURL) {
            var urlRequest = URLRequest(url: url)
            urlRequest.addValue("token \(Github.token)", forHTTPHeaderField: "Authorization")
            let session = URLSession.shared
            let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if let status = response as? HTTPURLResponse {
                    completion(status.statusCode == 204)
                }
            })
            dataTask.resume()
        }
    }
    
    class func starRepository(named: String, completion: @escaping () -> Void) {
        let baseURL = "https://api.github.com/user/starred/\(named)"
        Alamofire.request(baseURL, method: .put, headers: ["Authorization" : "token \(Github.token)"]).responseJSON { (_) in }
        
        
//        if let url = URL(string: baseURL) {
//            var urlRequest = URLRequest(url: url)
//            urlRequest.addValue("token \(Github.token)", forHTTPHeaderField: "Authorization")
//            urlRequest.addValue("0", forHTTPHeaderField: "Content-Length")
//            urlRequest.httpMethod = "PUT"
//            let session = URLSession.shared
//            let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
//                
//                completion()
//            })
//            dataTask.resume()
//        }
    }
    
    class func unstarRepository(named: String, completion: @escaping () -> Void) {
        let baseURL = "https://api.github.com/user/starred/\(named)"
        Alamofire.request(baseURL, method: .delete, headers: ["Authorization" : "token \(Github.token)"]).responseJSON { (response) in
            print(response)
        }
        
//        if let url = URL(string: baseURL) {
//            var urlRequest = URLRequest(url: url)
//            urlRequest.addValue("token \(Github.token)", forHTTPHeaderField: "Authorization")
//            urlRequest.httpMethod = "DELETE"
//            let session = URLSession.shared
//            let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
//                completion()
//            })
//            dataTask.resume()
//        }
    }
    
    class func toggleStarStatus(for named: String, completion: @escaping (Bool) -> Void) {
        self.checkIfRepositoryIsStarred(named) { (starred) in
            if starred {
                self.unstarRepository(named: named, completion: {})
                completion(false)
            } else if !starred {
                self.starRepository(named: named, completion: {})
                completion(true)
                
            }
        }
    }
    
    class func searchForRepo(searchTerms: String, completion: @escaping ([[String:Any]]) -> Void) {
        let urlString = "https://api.github.com/search/repositories?q=\(searchTerms)"
        Alamofire.request(urlString).responseJSON { response in
            let dictionary = response.result.value as? [String:Any]
            let json = dictionary?["items"] as? [[String:Any]] ?? [[:]]
            completion(json)
        }
    }
}
