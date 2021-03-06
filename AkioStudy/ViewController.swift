//
//  ViewController.swift
//  AkioStudy
//
//  Created by ouyou on 2021/07/14.
//

import UIKit

struct Human: Decodable {
    let name: String
    let avatarURL: URL
    
    enum CodingKeys:String, CodingKey {
        case name = "login"
        case avatarURL = "avatar_url"
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var userNameTexyField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBAction func didTapButton2(_ sender: Any) {
        activityIndicatorView.startAnimating()
        HumanAPI().fetchData(userName: userNameTexyField.text ?? "",
                             success: { human in
                                DispatchQueue.main.async {
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.isHidden = true
                                    let urlStr = human.avatarURL
                                    
                                    do {
                                        let data = try Data(contentsOf: urlStr)
                                        self.profileImageView.image = UIImage(data: data)
                                        
                                       } catch let err {
                                           print("Error : \(err.localizedDescription)")
                                       }
                                }
                                
                             }, error: {
                                DispatchQueue.main.async {
                                    self.activityIndicatorView.stopAnimating()
                                }
                                
                             })
        
    }
    
    struct HumanAPI {
        
        
        func fetchData(userName: String, success: @escaping (Human) -> Void, error: @escaping () -> Void) {
            DispatchQueue.global().async {
                
                guard let url = URL(string: "https://api.github.com/users/\(userName)") else {
                    error()
                    return
                }
                
                URLSession.shared.dataTask(with: url, completionHandler: {data, response, err in
                    if err != nil{
                        error()
                        return
                    }
                    
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        error()
                        return
                        
                    }
                    
                    switch response.statusCode {
                    case 200:
                        let decoder = JSONDecoder()
                        let human = try? decoder.decode(Human.self, from: data)
                        guard let human = human else {
                            return
                        }
                        success(human)
                    default:
                        error()
                    }
                }).resume()
                
            }
            
        }
    }
    
    
    @IBAction func didTapDownload(_ sender: Any) {
        activityIndicatorView.startAnimating()
        
        UserDownloader().downloadUser(
            userName: userNameTexyField.text ?? "",
            success:{user in //????????????????????????Human?????????
                ImageDownLoader().download( //??????????????????????????????????????????????????????api??????????????????url?????????????????????????????????????????????data???????????????image
                    url: user.avatarURL,
                    success: {image in
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicatorView.stopAnimating()
                            self?.activityIndicatorView.isHidden = true
                            self?.profileImageView.image = image
                        }
                        
                    },
                    error: { [weak self] in
                        DispatchQueue.main.async {
                            self?.activityIndicatorView.stopAnimating()
                        }
                        
                    })
            },
            error:  { [weak self] in
                DispatchQueue.main.async {
                    self?.activityIndicatorView.stopAnimating()
                }
            }
        )
    }
    
    struct UserDownloader {
        func downloadUser(
            userName: String,
            success: @escaping (Human) -> Void,
            error: @escaping ()-> Void) {
            guard let url = URL(string: "https://api.github.com/users/\(userName)") else {
                error()
                return
            }
            
            DataDownloader().download(url: url,success: { data in
                    let decoder = JSONDecoder()
                    if let human = try? decoder.decode(Human.self,from:data)
                    {
                        success(human)
                        
                    }else {
                        error()
                    }
                },
                error: error
                
            )
        }
    }
    
    struct ImageDownLoader {
        func download(url: URL, success: @escaping (UIImage) -> Void, error: @escaping () -> Void){
            
            DispatchQueue.global().async {
                DataDownloader().download(
                    url: url,
                    success: { data in
                        if let image = UIImage(data: data) {
                            success(image) //??????data??????data??????image????????????????????????
                        } else {
                            error()
                        }
                    },
                    error: error
                    
                )
            }
            
        }
    }
    
    struct DataDownloader {
        func download(url: URL, success: @escaping (Data) -> Void, error: @escaping () -> Void) {
            
            URLSession.shared.dataTask(with: url, completionHandler: {data, response,err in
                if err != nil{
                    error()
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    error()
                    return
                    
                }
                
                switch response.statusCode {
                case 200:
                    success(data) //?????????data????????????????????????
                default:
                    error()
                }
            }).resume()
        }
    }
    
}

