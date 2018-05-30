//
//  ViewController+DownloaderDelegate.swift
//  BasicStreamingEngine
//
//  Created by Syed Haris Ali on 1/7/18.
//  Copyright © 2018 Ausome Apps LLC. All rights reserved.
//

import Foundation
import FileStreamer
import os.log

extension ViewController: DownloadableDelegate {
    func download(_ download: Downloadable, completedWithError error: Error?) {
        os_log("%@ - %d [error: %@]", log: ViewController.logger, type: .debug, #function, #line, String(describing: error?.localizedDescription))
    }
    
    func download(_ download: Downloadable, changedState state: DownloadableState) {
        os_log("%@ - %d [state: %@]", log: ViewController.logger, type: .debug, #function, #line, String(describing: state))
    }
    
    func download(_ download: Downloadable, didReceiveData data: Data, progress: Float) {
        os_log("%@ - %d", log: ViewController.logger, type: .debug, #function, #line)
        
        guard let parser = parser else {
            os_log("Expected parser, bail...", log: ViewController.logger, type: .error)
            return
        }
        
        /// Parse the incoming audio into packets
        do {
            try parser.parse(data: data)
        } catch {
            os_log("Failed to parse: %@", log: ViewController.logger, type: .error, error.localizedDescription)
        }
        
        /// Once there's enough data to start producing packets we can use the data format
        if let _ = parser.dataFormat, reader == nil {
            do {
                reader = try Reader(parser: parser, readFormat: readFormat)
            } catch {
                os_log("Failed to create reader: %@", log: ViewController.logger, type: .error, error.localizedDescription)
            }
        }
        
        /// Update the progress UI
        DispatchQueue.main.async {
            [weak self] in
            self?.progressSlider.progress = progress
            
            if let duration = self?.parser?.duration {
                let formattedDuration = self?.formatToMMSS(duration)
                self?.durationTimeLabel.text = formattedDuration
                self?.durationTimeLabel.isEnabled = true
                self?.progressSlider.isEnabled = true
                self?.progressSlider.minimumValue = 0.0
                self?.progressSlider.maximumValue = Float(duration)
            }
        }
    }
}
