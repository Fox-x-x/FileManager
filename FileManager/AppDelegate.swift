//
//  AppDelegate.swift
//  FileManager
//
//  Created by Pavel Yurkov on 05.04.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private lazy var imagePicker: UIImagePickerController = {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        return vc
    } ()
    
    private lazy var viewController: ViewController = {
        let vc = ViewController()
        vc.imagePicker = imagePicker
        return vc
    }()
    
    private lazy var navController: UINavigationController = {
        let nc = UINavigationController(rootViewController: viewController)
        return nc
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }


}

