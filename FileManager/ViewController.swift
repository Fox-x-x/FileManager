//
//  ViewController.swift
//  FileManager
//
//  Created by Pavel Yurkov on 05.04.2021.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var paths: [URL] = []
    private lazy var fileManager = FileManager.default
    private var currentDir: URL?
    
    private lazy var createFolderButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(createFolderButtonItemTapped))
        return button
    }()
    
    private lazy var addPhotoButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotoButtonItemTapped))
        return button
    }()
    
    private lazy var goUpButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.turn.left.up"), style: .plain, target: self, action: #selector(goUpButtonItemTapped))
        return button
    }()
    
    private lazy var filesTableView: UITableView = {
        let ftv = UITableView()
        ftv.dataSource = self
        ftv.delegate = self
        ftv.showsVerticalScrollIndicator = false
        ftv.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        return ftv
    }()
    
    weak var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "FileManager"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItems = [createFolderButtonItem, addPhotoButtonItem]
        navigationItem.leftBarButtonItem = goUpButtonItem
        setupLayout()
        
        imagePicker?.delegate = self

        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        currentDir = dirPaths
        
        showFilesFor(dir: dirPaths, using: fileManager)
        
    }

    func showFilesFor(dir: URL, using fileManager: FileManager) {
        do {
            try paths = fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [], options: .includesDirectoriesPostOrder)
            goUpButtonItem.isEnabled = true
            filesTableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc private func createFolderButtonItemTapped() {
        
        let alert = UIAlertController(title: "Create new directory", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Create", style: .default) { [weak self] (action) in
            
            guard let vc = self else { return }
            
            if let dir = vc.currentDir, let name = alert.textFields?.first?.text {
                var newDir = dir
                newDir.appendPathComponent(name)
                do {
                    try vc.fileManager.createDirectory(at: newDir, withIntermediateDirectories: false, attributes: nil)
                    vc.showFilesFor(dir: dir, using: vc.fileManager)
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Type in dir name"
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc private func addPhotoButtonItemTapped() {
        if let photoPicker = imagePicker {
            present(photoPicker, animated: true, completion: nil)
        }
    }
    
    @objc private func goUpButtonItemTapped() {
        if let dir = currentDir {
            
            let upDir = dir.deletingLastPathComponent()
            showFilesFor(dir: upDir, using: fileManager)
            currentDir = upDir
            
            if currentDir?.lastPathComponent == "/" {
                goUpButtonItem.isEnabled = false
            }
        }
    }

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = filesTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = String(describing: paths[indexPath.row].lastPathComponent)
        
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentDir = paths[indexPath.row]
        showFilesFor(dir: paths[indexPath.row], using: fileManager)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageURL = info[.imageURL] as? URL {
            
            let photoName = imageURL.lastPathComponent
            let photoDestinationURL = currentDir?.appendingPathComponent(photoName)
            
            if let url = photoDestinationURL {
                do {
                    try fileManager.copyItem(at: imageURL, to: url)
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        }
        
        picker.dismiss(animated: true) { [weak self] in
            if let vc = self {
                if let dir = vc.currentDir {
                    vc.showFilesFor(dir: dir, using: vc.fileManager)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

private extension ViewController {
    
    func setupLayout() {
        
        view.addSubviewWithAutolayout(filesTableView)
        
        let constraints = [
            
            filesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            filesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}



