//
//  NextViewController.swift
//  BLE_YuhashiLab
//
//  Created by takagi on 2022/02/22.
//

import UIKit
import CoreLocation

class NextViewController: UIViewController , CLLocationManagerDelegate {
    //beaconの値取得関係の変数
    var trackLocationManager : CLLocationManager!
    var beaconRegion : CLBeaconRegion!
    var satisfyingIConstraint : CLBeaconIdentityConstraint!
    //アラートの変数
    var alertController: UIAlertController!
    
    
    @IBOutlet weak var idname: UILabel!
    
    
    @IBOutlet weak var list: UILabel!
    
    @IBOutlet weak var fromId: UILabel!
    var fixedId = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        idname.text = fixedId
        
        ///add
        print("Application Start")
        // ロケーションマネージャの作成
        trackLocationManager = CLLocationManager();
        trackLocationManager.delegate = self;
        // BeaconのUUIDを設定
        let uuid:UUID? = UUID(uuidString: "1233aacc-0dc1-40a7-8085-303a6d64ddb5")
        //Beacon領域を作成
        if #available(iOS 13, *) {
            //iOS13以降
            beaconRegion = CLBeaconRegion(uuid: uuid!, identifier: "BeaconApp")
        } else {
            //iOS13以前
            beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "BeaconApp")
        }
        var anyStatus:CLAuthorizationStatus
        // セキュリティ認証のステータスを取得
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if #available(iOS 14, *){
            anyStatus = trackLocationManager.authorizationStatus
            if (anyStatus != CLAuthorizationStatus.authorizedWhenInUse) {
                trackLocationManager.requestWhenInUseAuthorization()
            }
        } else {
            anyStatus = CLLocationManager.authorizationStatus()
            if (anyStatus != CLAuthorizationStatus.authorizedWhenInUse) {
                trackLocationManager.requestWhenInUseAuthorization()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //画面をスリープさせない
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    // 位置情報の認証ステータス変更
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            // ビーコン領域の観測を開始
            print("ビーコン領域の観測を開始")
            self.trackLocationManager.startMonitoring(for: self.beaconRegion)
        }
    }
    
    //観測の開始に成功すると呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("ビーコンの観測の開始に成功")
        //観測開始に成功したら、領域内にいるかどうかの判定をおこなう。
        trackLocationManager.requestState(for: self.beaconRegion)
    }
    

    
    // ビーコン領域のステータスを取得
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {

        switch (state) {
        case .inside: // ビーコン領域内
            // ビーコンの測定を開始
            self.trackLocationManager.startRangingBeacons(satisfying: self.beaconRegion.beaconIdentityConstraint)
            break
        case .outside:
            print("ビーコン領域外")// ビーコン領域外
            break
        case .unknown:
            print("ビーコン領域不明")// 不明
            break
        }
    }
    
    //領域に入った時
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            print("ビーコンの領域に入った")
            // →(didRangeBeacons)で測定をはじめる
            if #available (iOS 13, *){
                if let beaconUnwrap = self.satisfyingIConstraint {
                    self.trackLocationManager.startRangingBeacons(satisfying: beaconUnwrap)
                }
            }else{
                self.trackLocationManager.startRangingBeacons(in: self.beaconRegion)
            }
        }
    
    //領域から出た時
        func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            //測定を停止する
            print("ビーコンの位置測定を停止（領域から出た）")
            if #available(iOS 13, *){
                if let beaconUnwrap = self.satisfyingIConstraint {
                    self.trackLocationManager.stopRangingBeacons(satisfying: beaconUnwrap)}
            } else {
                self.trackLocationManager.stopRangingBeacons(in: self.beaconRegion)
            }
        }


    // ビーコンの位置測定
        func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
            print("ビーコンの位置測定")
            
            
            var bindData = [BatchEntity]()
            
            for beacon in beacons {
                Log.write("fixedId:\(fixedId),\(beacon)\n")
                //ここにFIWAREに送信する部分を書く
//                if(fixedId == ""){
//                    print("emptyid")
//                }else{
//                // /////////////

//            do{
//                try ApiClient.postData(deviceId: fixedId, time: beacon.timestamp, minorBeaconId: String(describing: beacon.minor), majorBeaconId: String(describing: beacon.major), rssi: Double(beacon.rssi))
//                    print("request success?")
//
//            } catch {
//                           print("got error: \(error)")
//            }
                ////////
//              print("fixedId:\(fixedId)") //fixedIdは最初に入力してもらう識別番号（それぞれの持つタグのminor値）
//                print("uuid:\(beacon.uuid)")
//                print("major:\(beacon.major)")
                print("minor:\(beacon.minor)")
                if (beacon.proximity == CLProximity.immediate) {
                    print("proximity:immediate")
                }
                if (beacon.proximity == CLProximity.near) {
                    print("proximity:near")
                }
                if (beacon.proximity == CLProximity.far) {
                    print("proximity:Far")
                }
                if (beacon.proximity == CLProximity.unknown) {
                    print("proximity:unknown")
                }
                print("accuracy:\(beacon.accuracy)")
             //   print("rssi:\(beacon.rssi)")
                print("timestamp:\(beacon.timestamp)")
                // bind
                list.text = "\(beacon.timestamp)"
                fromId.text = "ID:\(beacon.minor)"
                //
                bindData += [BatchEntity(time: beacon.timestamp, minorBeaconId: String(describing: beacon.minor), majorBeaconId: String(describing: beacon.major), rssi: Double(beacon.rssi))]
                
            }
//bind request
      do{
                    try ApiClient.postDataBatch(deviceId: fixedId, data : bindData)
                    print(bindData)
          
          
        } catch {
                       print("bind request error: \(error)")
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

}
