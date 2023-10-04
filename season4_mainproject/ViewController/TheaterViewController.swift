//
//  TheaterViewController.swift
//  season4_mainproject
//
//  Created by TJ on 2023/09/21.
//
import UIKit
import WebKit
import CoreLocation

class TheaterViewController: UIViewController, CLLocationManagerDelegate {
    let PORT = Bundle.main.object(forInfoDictionaryKey: "PORT") as? String ?? ""
    let HOST = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String ?? ""
    
    var locationManger = CLLocationManager()
    var currentLatitude: Double?
    var currentLongitude: Double?
    
    @IBOutlet var theaterWebView: WKWebView!
    @IBOutlet var myActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        theaterWebView.navigationDelegate = self
        
        // 위치 서비스 설정
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        // 위치 서비스 권한을 백그라운드 스레드에서 요청
        DispatchQueue.global().async {
            self.checkLocationAuthorizationStatus()
        }
    }
    
    // 위치 권한 상태 확인 및 처리
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                switch locationManger.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    // 위치 서비스 승인됨
                    startLocationUpdates()
                case .denied, .restricted:
                    // 위치 서비스 거부 또는 제한됨
                    showLocationDeniedAlert()
                case .notDetermined:
                    // 위치 권한 미확정, 권한 요청
                    locationManger.requestWhenInUseAuthorization()
                default:
                    break
                }
            } else {
                // iOS 14 이상이 아닌 경우, 이전 방식으로 처리
                switch CLLocationManager.authorizationStatus() {
                case .authorizedWhenInUse, .authorizedAlways:
                    // 위치 서비스 승인됨
                    startLocationUpdates()
                case .denied, .restricted:
                    // 위치 서비스 거부 또는 제한됨
                    showLocationDeniedAlert()
                case .notDetermined:
                    // 위치 권한 미확정, 권한 요청
                    locationManger.requestWhenInUseAuthorization()
                default:
                    break
                }
            }
        } else {
            // 위치 서비스 비활성화
            showLocationDisabledAlert()
        }
    }
    
    
    // 위치 업데이트 시작
    func startLocationUpdates() {
        locationManger.startUpdatingLocation()
    }
    
    // 위치 업데이트 중지
    func stopLocationUpdates() {
        locationManger.stopUpdatingLocation()
    }
    
    // 사용자에게 위치 서비스가 거부된 경우 표시할 알림
    func showLocationDeniedAlert() {
        let alertController = UIAlertController(title: "Location Access Denied", message: "Please enable location access in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // UI 업데이트는 메인 스레드에서 처리
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // 사용자에게 위치 서비스가 비활성화된 경우 표시할 알림
    func showLocationDisabledAlert() {
        let alertController = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // UI 업데이트는 메인 스레드에서 처리
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let location = locations.first {
            currentLatitude = abs(location.coordinate.latitude)
            currentLongitude = abs(location.coordinate.longitude)
            print("위도: \(currentLatitude ?? 0.0)")
            print("경도: \(currentLongitude ?? 0.0)")
            
            // 위치 정보를 사용하여 웹뷰를 로드합니다.
            loadWebViewWithLocation()
        }
    }
    
    // 위치 정보를 사용하여 웹뷰를 로드하는 함수
        func loadWebViewWithLocation() {
            if let _ = currentLatitude, let _ = currentLongitude {
                let _ = SiteRequest()
                let urlString = "\(HOST):\(PORT)/map/preview"
                
                if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                    if let myURL = URL(string: urlString) {
                        let myRequest = URLRequest(url: myURL)
                        
                        // UI 업데이트는 메인 스레드에서 처리
                        DispatchQueue.main.async {
                            self.theaterWebView.load(myRequest)
                        }
                    } else {
                        print("Invalid URL: \(urlString)")
                    }
                } else {
                    print("URL does not have a valid prefix: \(urlString)")
                }
            }
        }
    }


extension TheaterViewController: WKNavigationDelegate{
    // Indicator 시작
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        myActivityIndicator.startAnimating()
        myActivityIndicator.isHidden = false
    } // didCommit으로 찾으면 된다.
    
    // Indicator 종료
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
    }
    // Error 발생시
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
    }
}
