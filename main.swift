//
//  AppDelegate.swift
//  Gandi-Swift
//
//  Created by 左安之 on 2025/11/10.
//

import Cocoa
import WebKit

// 自定义WebView类，用于处理键盘事件
class CustomWebView: WKWebView {
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        // 允许WebView处理键盘事件
        super.keyDown(with: event)
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        // 处理键盘快捷键
        return super.performKeyEquivalent(with: event)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 创建主窗口
        let windowSize = NSSize(width: 1366, height: 768)
        let windowRect = NSRect(origin: .zero, size: windowSize)
        
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Gandi"
        window.center()
        
        // 创建自定义WebView
        let webView = CustomWebView(frame: windowRect)
        
        // 配置WebView以接受键盘输入
        // 使用兼容的方式启用JavaScript
        webView.configuration.preferences.setValue(true, forKey: "javaScriptEnabled")
        
        // 获取可执行文件路径并构建资源路径
        let executablePath = Bundle.main.executablePath ?? ProcessInfo.processInfo.arguments.first ?? "/usr/bin/swift"
        let executableURL = URL(fileURLWithPath: executablePath)
        let executableDir = executableURL.deletingLastPathComponent()
        
        // 尝试不同的资源路径
        var htmlFileURL: URL?
        
        // 1. 首先尝试从bundle资源目录查找
        let bundle = Bundle.main
        if let resourcePath = bundle.path(forResource: "index", ofType: "html", inDirectory: "Pages") {
            htmlFileURL = URL(fileURLWithPath: resourcePath)
            print("从bundle资源中找到HTML文件: \(htmlFileURL?.path ?? "未知")")
        }
        
        // 2. 如果bundle中找不到，尝试从可执行文件目录的Gandi-Swift_Gandi-Swift.bundle中查找
        if htmlFileURL == nil {
            let bundleDir = executableDir.appendingPathComponent("Gandi-Swift_Gandi-Swift.bundle")
            let pagesDir = bundleDir.appendingPathComponent("Pages")
            let indexPath = pagesDir.appendingPathComponent("index.html")
            
            if FileManager.default.fileExists(atPath: indexPath.path) {
                htmlFileURL = indexPath
                print("从bundle目录中找到HTML文件: \(indexPath.path)")
            }
        }
        
        // 3. 如果还找不到，尝试从可执行文件目录直接查找
        if htmlFileURL == nil {
            let pagesDir = executableDir.appendingPathComponent("Pages")
            let indexPath = pagesDir.appendingPathComponent("index.html")
            
            if FileManager.default.fileExists(atPath: indexPath.path) {
                htmlFileURL = indexPath
                print("从可执行文件目录中找到HTML文件: \(indexPath.path)")
            }
        }
        
        // 4. 尝试从Swift Package Manager构建目录查找
        if htmlFileURL == nil {
            let buildDir = executableDir.deletingLastPathComponent().appendingPathComponent("Gandi-Swift_Gandi-Swift.bundle")
            let pagesDir = buildDir.appendingPathComponent("Pages")
            let indexPath = pagesDir.appendingPathComponent("index.html")
            
            if FileManager.default.fileExists(atPath: indexPath.path) {
                htmlFileURL = indexPath
                print("从构建目录中找到HTML文件: \(indexPath.path)")
            }
        }
        
        // 5. 尝试从Xcode构建目录查找
        if htmlFileURL == nil {
            let bundleDir = executableDir.appendingPathComponent("Gandi-Swift_Gandi-Swift.bundle")
            let resourcesDir = bundleDir.appendingPathComponent("Contents").appendingPathComponent("Resources")
            let indexPath = resourcesDir.appendingPathComponent("index.html")
            
            if FileManager.default.fileExists(atPath: indexPath.path) {
                htmlFileURL = indexPath
                print("从Xcode构建目录中找到HTML文件: \(indexPath.path)")
            }
        }
        
        // 6. 最后尝试从开发环境的Sources目录查找
        if htmlFileURL == nil {
            let sourcesDir = executableDir.deletingLastPathComponent().appendingPathComponent("Sources")
            let pagesDir = sourcesDir.appendingPathComponent("Pages")
            let indexPath = pagesDir.appendingPathComponent("index.html")
            
            if FileManager.default.fileExists(atPath: indexPath.path) {
                htmlFileURL = indexPath
                print("从开发目录中找到HTML文件: \(indexPath.path)")
            }
        }
        
        if let htmlFileURL = htmlFileURL, FileManager.default.fileExists(atPath: htmlFileURL.path) {
            // 加载找到的HTML文件
            let pagesDir = htmlFileURL.deletingLastPathComponent()
            webView.loadFileURL(htmlFileURL, allowingReadAccessTo: pagesDir)
            print("成功加载HTML文件: \(htmlFileURL.path)")
        } else {
            // 文件不存在，显示错误信息
            let errorHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>文件未找到</title>
                <style>
                    body { font-family: -apple-system, sans-serif; padding: 40px; text-align: center; }
                    h1 { color: #ff3b30; }
                    p { color: #666; }
                </style>
            </head>
            <body>
                <h1>文件未找到</h1>
                <p>无法找到HTML文件</p>
                <p>可执行文件路径: \(executablePath)</p>
                <p>可执行文件目录: \(executableDir.path)</p>
            </body>
            </html>
            """
            webView.loadHTMLString(errorHTML, baseURL: nil)
            print("错误: 无法找到HTML文件")
            print("可执行文件路径: \(executablePath)")
            print("可执行文件目录: \(executableDir.path)")
        }
        
        // 设置窗口内容
        window.contentView = webView
        window.makeKeyAndOrderFront(nil)
        
        // 确保WebView成为第一响应者以接收键盘事件
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.window.makeFirstResponder(webView)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// 启动应用程序
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()