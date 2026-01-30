//
//  background_manager.swift
//  Runner
//
//  Created by admin on 2026/1/28.
//

import Foundation


class BackgroundManager {
    
    private var timer: Timer?
        
        // Таймерыг эхлүүлэх функц
        func startPrinting() {
            // Хэрэв өмнө нь ажиллаж байсан таймер байвал зогсооно
            stopPrinting()
            
            // 5 секунд тутамд давтагдах таймер үүсгэх
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                print("Hello World")
            }
            
            print("Таймер эхэллээ...")
        }
        
        // Таймерыг зогсоох функц
        func stopPrinting() {
            timer?.invalidate()
            timer = nil
            print("Таймер зогслоо.")
        }
}
