//
//  ReviewViewController.swift
//  season4_mainproject
//
//  Created by Kang Hyeon Oh on 2023/09/25.
//
import Cosmos
import UIKit

class ReviewViewController: UIViewController {

    let aicontroller = AIController(service: AiService())
    let controller = ReviewController(service: ReviewService())

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblGenre: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var ImgView: UIImageView!
    @IBOutlet weak var lblRelease: UILabel!
    @IBOutlet weak var cosmosOh: CosmosView!
    @IBOutlet weak var tfReview: UITextField!
    var editmode : Bool = false
    var receivedId: Int = 0
    var receivedTitle: String = ""
    var receivedGenre: String = ""
    var receivedCountry: String = ""
    var imagePath: String = ""
    var receivedRelease: String = ""
    var rating : Double = 4.0


    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = receivedTitle
        lblGenre.text = receivedGenre
        lblCountry.text = receivedCountry
        lblRelease.text = receivedRelease
        urlImage(imagePath)
        // Do any additional setup after loading the view.
        // 코스모스 설정
        cosmosOh.settings.fillMode = .precise
        cosmosOh.rating = rating
        cosmosOh.settings.starSize = 30
        cosmosOh.settings.starMargin = 5
    }

    func urlImage(_ imagePath: String) {
        let imageUrl = URL(string: imagePath)

        // 이미지 다운로드는 백그라운드 스레드에서 수행
        DispatchQueue.global().async {
            if let imageUrl = imageUrl, let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                // 이미지 크기 조정
                let imageSize = CGSize(width: 170, height: 175) // 원하는 크기로 조절
                UIGraphicsBeginImageContext(imageSize)
                image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
                if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
                    // UI 업데이트는 메인 스레드에서 수행
                    DispatchQueue.main.async { [weak self] in
                        self?.ImgView.image = resizedImage
                    }
                }
                UIGraphicsEndImageContext()
                // 이제 이미지 크기 조정 코드가 정상적으로 동작합니다.
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnCheck(_ sender: UIButton) {
        var result: String = "Dummy"
        var percentage: String = "0" // 초기화

        aicontroller.aiResultMessage(review: tfReview.text!) { [self] message, percentageResult in
            result = message
            percentage = percentageResult
            DispatchQueue.main.async { // UI 업데이트를 메인 스레드에서 실행
                self.imageAlert((Any).self, result: result, percentage: percentage)
            }
        }
    }




    @objc func imageAlert(_ sender: Any, result: String, percentage: String) {
        // 커스텀 UIViewController를 생성합니다.
        let customViewController = UIViewController()

        // 커스텀 뷰 컨트롤러의 크기를 설정합니다.
        let customViewSize = CGSize(width: 300, height: 200) // 원하는 크기로 조정합니다.
        customViewController.preferredContentSize = customViewSize

        // UIAlertController를 생성합니다.
        let alertController = UIAlertController(title: "댓글 AI 측정", message: "\n\(result)", preferredStyle: .alert)

        // OK 액션을 추가합니다.
        let OKACTION = UIAlertAction(title: "OK", style: .default) { [self] _ in
            navigationController?.popViewController(animated: true)
        }
        alertController.addAction(OKACTION)

        // 별점 뷰를 생성하고 설정합니다.
        let cosmosView = CosmosView()
        cosmosView.settings.fillMode = .precise
        cosmosView.settings.updateOnTouch = false
        self.rating = Double(percentage)! * 100 / 20.0
        cosmosView.rating = self.rating
        self.cosmosOh.rating = self.rating

        // UIAlertController를 커스텀 뷰 컨트롤러의 하위 뷰로 추가합니다.
        customViewController.addChild(alertController)
        customViewController.view.addSubview(alertController.view)
        alertController.didMove(toParent: customViewController)

        // UIAlertController를 커스텀 뷰 컨트롤러의 가운데에 배치합니다.
        alertController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertController.view.centerXAnchor.constraint(equalTo: customViewController.view.centerXAnchor),
            alertController.view.centerYAnchor.constraint(equalTo: customViewController.view.centerYAnchor),
            alertController.view.widthAnchor.constraint(equalToConstant: customViewSize.width),
            alertController.view.heightAnchor.constraint(equalToConstant: customViewSize.height)
            ])

        // 별점 뷰를 UIAlertController 내에 추가합니다.
        alertController.view.addSubview(cosmosView)

        // 별점 뷰의 위치를 조정합니다.
        cosmosView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cosmosView.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor),
            cosmosView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 100) // 메시지 아래에 80포인트 떨어진 위치
            ])

        // 커스텀 뷰 컨트롤러를 Modal로 표시합니다.
        self.present(customViewController, animated: true)
    }

    @IBAction func btnSave(_ sender: UIButton) {
        var rating: Double = cosmosOh.rating
        var saveResult : Bool
        let content = tfReview.text!
        rating = (rating * 100).rounded() / 100
        
        if editmode{
            saveResult = controller.updateReview(movie_id: receivedId, content: content, rating: rating)
        }else{
            saveResult = controller.insertReview(movie_id: receivedId, content: content, rating: rating)
        }
       

        if saveResult {
            // 저장 성공
            let alertController = UIAlertController(title: "저장 완료", message: "리뷰가 성공적으로 저장되었습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.dismiss(animated: true) {
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else {
            // 저장 실패
            let alertController = UIAlertController(title: "저장 실패", message: "리뷰 저장 중 오류가 발생했습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }

    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
/*
    // MARK: -EXTENSION
 */
