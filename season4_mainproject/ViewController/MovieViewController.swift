//
//  MovieViewController.swift
//  season4_mainproject
//
//  Created by TJ on 2023/09/26.
//
import UIKit

class MovieViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    
    @IBOutlet weak var cvDramaView: UICollectionView!
    @IBOutlet weak var cvOTTView: UICollectionView!
    @IBOutlet weak var cvListView: UICollectionView!
    @IBOutlet weak var cvAnimeView: UICollectionView!
    @IBOutlet weak var cvRomanceView: UICollectionView!
    
    @IBOutlet weak var btnUserName: UIBarButtonItem!
    
    var movieList: [MovieModel] = []
    var rankList: [MovieModel] = []
    var ottList: [MovieModel] = []
    var dramaList: [MovieModel] = []
    var animeList: [MovieModel] = []
    var romanceList: [MovieModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션바, 탭바 스크롤 시에도 색상 유지하는 기능
        naviAndTabSetting()
        
        setDelegateAndDataSource(cvDramaView)
        setDelegateAndDataSource(cvOTTView)
        setDelegateAndDataSource(cvListView)
        setDelegateAndDataSource(cvAnimeView)
        setDelegateAndDataSource(cvRomanceView)
        // 컬렉션뷰 수평 스크롤 세팅
        horizontalSetting(cvDramaView)
        horizontalSetting(cvOTTView)
        horizontalSetting(cvListView)
        horizontalSetting(cvAnimeView)
        horizontalSetting(cvRomanceView)
        // 컬렉션뷰 배경 투명하게
        clearBackGround(cvDramaView)
        clearBackGround(cvOTTView)
        clearBackGround(cvListView)
        clearBackGround(cvAnimeView)
        clearBackGround(cvRomanceView)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        rankList = []
        ottList = []
        dramaList = []
        animeList = []
        romanceList = []

        btnUserName.title = UserDefaults.standard.string(forKey: "name") == nil ? "" : "\(UserDefaults.standard.string(forKey: "name")!) 님"
        
        // 무비데이터 들고오기
        readValues()
    }
    
    // MARK: - UICollectionViewDataSource
    
    // 셀 개수 리턴
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvListView {
            return rankList.count
        }else if collectionView == cvOTTView {
            return ottList.count
        }else if collectionView == cvDramaView {
            return dramaList.count
        }else if collectionView == cvAnimeView {
            return animeList.count
        }else if collectionView == cvRomanceView {
            return romanceList.count
        }
        return 0
    }
    
    // 셀별 세팅
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        switch collectionView {
        case cvListView:
            cell = cvListView.dequeueReusableCell(withReuseIdentifier: "rankCell", for: indexPath) as! MovieCollectionViewCell
            let movieCell = cell as! MovieCollectionViewCell
            movieCell.lblRank.text = "\(indexPath.row + 1)"
            makeLabelBorder(UILabel: movieCell.lblRank)
            let imagePath = rankList[indexPath.row].imagepath
            let trimmedImagePath = imagePath.trimmingCharacters(in: .whitespacesAndNewlines)
            configureCell(cell as! MovieCollectionViewCell, withImageURL: trimmedImagePath)
            
        case cvOTTView:
            cell = cvOTTView.dequeueReusableCell(withReuseIdentifier: "ottCell", for: indexPath) as! OTTCollectionViewCell
            let ottCell = cell as! OTTCollectionViewCell
            //티빙 왓챠 웨이브
            if ottList[indexPath.row].ott == "티빙" {
                ottCell.lblOTT.backgroundColor = UIColor.orange
            } else if ottList[indexPath.row].ott == "왓챠" {
                ottCell.lblOTT.backgroundColor = UIColor.red
            } else {
                ottCell.lblOTT.backgroundColor = UIColor.blue
            }
            ottCell.lblOTT.text = ottList[indexPath.row].ott
            configureCell(cell as! OTTCollectionViewCell, withImageURL: ottList[indexPath.row].imagepath)
            
        case cvDramaView:
            cell = cvDramaView.dequeueReusableCell(withReuseIdentifier: "dramaCell", for: indexPath) as! DramaCollectionViewCell
            configureCell(cell as! DramaCollectionViewCell, withImageURL: dramaList[indexPath.row].imagepath)
            
        case cvAnimeView:
            cell = cvAnimeView.dequeueReusableCell(withReuseIdentifier: "animeCell", for: indexPath) as! AnimeCollectionViewCell
            configureCell(cell as! AnimeCollectionViewCell, withImageURL: animeList[indexPath.row].imagepath)
            
        case cvRomanceView:
            cell = cvRomanceView.dequeueReusableCell(withReuseIdentifier: "romanceCell", for: indexPath) as! RomanceCollectionViewCell
            configureCell(cell as! RomanceCollectionViewCell, withImageURL: romanceList[indexPath.row].imagepath)
            
        default:
            cell = UICollectionViewCell()
        }
        
        return cell
    }

    // 셀 data 담아주기. 바로 위 셀별 세팅에서 호출해서 사용한다.
    func configureCell(_ cell: UICollectionViewCell, withImageURL imageUrlString: String) {
        let imageUrl = URL(string: imageUrlString)
        
        URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                // 비동기방식으로 이미지 불러와 담아주기
                DispatchQueue.main.async {
                    if let movieCell = cell as? MovieCollectionViewCell {
                        movieCell.movieImage.image = image
                    } else if let ottCell = cell as? OTTCollectionViewCell {
                        ottCell.movieImage.image = image
                    } else if let dramaCell = cell as? DramaCollectionViewCell {
                        dramaCell.movieImage.image = image
                    } else if let animeCell = cell as? AnimeCollectionViewCell {
                        animeCell.movieImage.image = image
                    } else if let romanceCell = cell as? RomanceCollectionViewCell {
                        romanceCell.movieImage.image = image
                    }
                }
            }
        }.resume()
    }

    // segment별 셀 클릭 시 데이터 넘겨주기(id값)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "sgDetail" {
                let cell = sender as! MovieCollectionViewCell
                let indexPath = self.cvListView.indexPath(for: cell)
                let detailView = segue.destination as! MovieDetailViewController
                detailView.receivedid = rankList[indexPath!.row].id
            }
            else if segue.identifier == "sgOTTDetail" {
                let cell = sender as! OTTCollectionViewCell
                let indexPath = self.cvOTTView.indexPath(for: cell)
                let detailView = segue.destination as! MovieDetailViewController
                detailView.receivedid = ottList[indexPath!.row].id
            }
            else if segue.identifier == "sgDramaDetail" {
                let cell = sender as! DramaCollectionViewCell
                let indexPath = self.cvDramaView.indexPath(for: cell)
                let detailView = segue.destination as! MovieDetailViewController
                detailView.receivedid = dramaList[indexPath!.row].id
            }
            else if segue.identifier == "sgAnimeDetail" {
                let cell = sender as! AnimeCollectionViewCell
                let indexPath = self.cvAnimeView.indexPath(for: cell)
                let detailView = segue.destination as! MovieDetailViewController
                detailView.receivedid = animeList[indexPath!.row].id
            }
            else if segue.identifier == "sgRomanceDetail" {
                let cell = sender as! RomanceCollectionViewCell
                let indexPath = self.cvRomanceView.indexPath(for: cell)
                let detailView = segue.destination as! MovieDetailViewController
                detailView.receivedid = romanceList[indexPath!.row].id
            }
        }
    
    // MARK: - ViewWillAppear Setting
    func naviAndTabSetting(){
        let naviAppearance = UINavigationBarAppearance()
        naviAppearance.backgroundColor = UIColor(named: "background")
        naviAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let tabbarAppearance = UITabBarAppearance()
        tabbarAppearance.backgroundColor = UIColor(named: "background")
        
        self.navigationController?.navigationBar.scrollEdgeAppearance = naviAppearance
        self.navigationController?.navigationBar.standardAppearance = naviAppearance
        self.navigationController?.navigationBar.compactAppearance = naviAppearance

        self.tabBarController?.tabBar.scrollEdgeAppearance = tabbarAppearance
        self.tabBarController?.tabBar.standardAppearance = tabbarAppearance
    }
    
    func setDelegateAndDataSource(_ view: UICollectionView){
        view.delegate = self
        view.dataSource = self
    }
    
    func horizontalSetting(_ view: UICollectionView){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        view.collectionViewLayout = layout
    }
    
    func clearBackGround(_ view: UICollectionView){
        view.backgroundColor = UIColor.clear
        view.backgroundView = nil
    }
    
    func readValues() {
        let movieQueryModel = JSONAMovieQueryModel()
        movieQueryModel.delegate = self
        movieQueryModel.fetchDataFromAPI()
    }
    
    // make border
    func makeLabelBorder(UILabel: UILabel){
        let attributedText = NSMutableAttributedString(string: UILabel.text!)
        attributedText.addAttribute(.strokeColor, value: UIColor.white, range: NSRange(location: 0, length: attributedText.length))
        attributedText.addAttribute(.strokeWidth, value: 4.0, range: NSRange(location: 0, length: attributedText.length))
        UILabel.attributedText = attributedText
    }

}

extension MovieViewController: JSONMovieQueryModelProtocol {
    func itemDownloaded(item: [MovieModel]) {
        movieList = item
        
        let sortedAudienceList = movieList.sorted(by: { $0.totalaudience > $1.totalaudience })
        let sortedDateList = movieList.sorted(by: { $0.releasedate > $1.releasedate })
        
        for (index, movie) in sortedAudienceList.prefix(10).enumerated() {
            rankList.append(movie)
            
            // 관객수 기준 상위 10개 담으면 빠져나오게
            if index == 9 {
                break
            }
        }
        
        for movie in sortedDateList{
            
            if movie.ott != "영화"{
                ottList.append(movie)
            }else{ // ott가 아닌 데이터 중에서 고르기
                if movie.genre.contains("드라마"){
                    dramaList.append(movie)
                }
                if movie.genre.contains("애니메이션"){
                    animeList.append(movie)
                }
                if movie.genre.contains("로맨스") || movie.genre.contains("멜로"){
                    romanceList.append(movie)
                }
            }
            
        }
        self.cvListView.reloadData()
        self.cvOTTView.reloadData()
        self.cvDramaView.reloadData()
        self.cvAnimeView.reloadData()
        self.cvRomanceView.reloadData()
    }
}

// 컬렉션뷰 사이즈와 간격 세팅
extension MovieViewController: UICollectionViewDelegateFlowLayout{
    // 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // 1픽셀
    }
    
    // 좌우 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // Cell Size ( 옆 라인을 고려하여 설정)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvListView {
            return CGSize(width: 154+10, height: 185)
        }else {
            return CGSize(width: 127+10, height: 185) // 마진 10 주기
        }
        
    }
    
}
