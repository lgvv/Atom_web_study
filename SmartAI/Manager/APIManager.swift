//
//  APIManager.swift
//  SmartAI
//
//  Created by Hamlit Jason on 2022/11/21.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

final class APIManager {
    static let shared = APIManager()
    
    private init() { }
    
    // TODO: - Rx + 클린 아키텍쳐 적용하기
    func uploadImage(for image: UIImage, _ completion: @escaping (Result<Banana, Error>) -> Void) {
        let header: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { MultipartFormData in
            if let image = image.jpegData(compressionQuality: 1.0) {
                MultipartFormData.append(image, withName: "request_img", fileName: "\(Date()).jpg", mimeType: "image/jpg")
            }
        }, to: ServerUrlString.urlString, method: .post, headers: header)
        .validate()
        .responseDecodable(of: Banana.self) { response in
            switch response.result {
            case .success(let result):
                print("업로드 성공 \(result)")
                completion(.success(result))
            case .failure(let error):
                // NOTE: - 서버에서 에러를 정의하지 않음.
                print("🚨 \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

    }
}

