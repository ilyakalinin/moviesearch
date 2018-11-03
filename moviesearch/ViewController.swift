//
//  ViewController.swift
//  moviesearch
//
//  Created by Ilya Kalinin on 03/11/2018.
//  Copyright © 2018 Ilya Kalinin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var movie: Movie?
    var poster: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let movie = movie {
            titleLabel.text = movie.title ?? "n/a"
            releaseLabel.text = "Release Date: " + (movie.release != nil && movie.release!.count > 0 ? movie.release! : "n/a")
            ratingLabel.text = "Rating: " + (movie.rating != 0.0 ? String(movie.rating) : "n/a")
            
            descriptionLabel.text = movie.description
        }
        
        posterImageView.image = poster
    }

}
