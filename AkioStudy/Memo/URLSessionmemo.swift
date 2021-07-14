//
//  URLSessionmemo.swift
//  AkioStudy
//
//  Created by ouyou on 2021/07/14.
//

import Foundation


class 通信做法  {
    
    
//     第一步 要根据api式样书，做一个class或者struct，里面的变量，式样怎么写，变量就设置成什么值
     
    struct Human: Decodable { // 实装Decodable协议
        let name: String
        let avatarURL: URL
        
        enum CodingKeys:String, CodingKey { //编译器会自动生成CodingKeys且型为enum，
                                            //这里要声明这个东西，让编译器知道api的哪个键对应这里的 哪个键
            case name = "login"
            case avatarURL = "avatar_url"
        }
    }
    
    
    func fetchData(userName: String, success: @escaping (Human) -> Void, error: @escaping () -> Void) {
        
//        在做通信时，因为通信这块比较繁琐，在测试界面显示是否正确时，可以用这个延迟执行的方法模拟通信进行了5秒，然后确认画面的显示
//        DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {print("hgfjldk;")})
    
        DispatchQueue.global().async { //非同期通信
            
            guard let url = URL(string: "https://api.github.com/users/\(userName)") else {
                error()
                return
            }
            
            URLSession.shared.dataTask(with: url, completionHandler: {data, response, err in //通信
                if err != nil{
                    error()
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    error()
                    return
                    
                }
                
                switch response.statusCode { //判断通信结果
                case 200:
                    let decoder = JSONDecoder() //解码器声明
                //开始解码，这时候就会由编译器生成CodingKeys,然后编译器就会去model中找这个enum，找到后，就会把api的键映射到model中的键，同时赋值
                    let human = try? decoder.decode(Human.self, from: data)
                    
                    guard let human = human else {
                        return
                    }
                    success(human) //把整个model返给调用方
                default:
                    error()
                }
            }).resume() //唤醒该请求，也可以理解为激活
            
        }
        
    }
}
    


