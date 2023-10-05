//
//  AIController.swift
//  season4_mainproject
//
//  Created by Kang Hyeon Oh on 2023/09/26.
//

import Foundation

class AIController {
    var service: AiService

    init(service: AiService) {
        self.service = service
    }

    func aiResultMessage(review: String, completion: @escaping (String, String) -> Void) {
        service.calcScore(review: review) { result in
            if let result = result {
                let message: String
                if result > 0.5 {
                    message = "\(String(result*100))% 확률로 긍정 리뷰입니다."
                } else {
                    message = "\(String((1-result)*100))% 확률로 부정 리뷰입니다."
                }
                print(message)
                completion(message, String(result))
            } else {
                completion("분석 결과를 가져올 수 없습니다.", "0") // 예외 처리: result가 nil인 경우
            }
        }
    }


}
