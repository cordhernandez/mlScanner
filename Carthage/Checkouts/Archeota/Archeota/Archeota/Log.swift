//
//  LOG.swift
//  Archeota
//
//  Created by Wellington Moreno on 8/27/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//


import Foundation

/**
    The Archeota Logger class.
 
    The logger will print messages by default. To programmatically disable the Logger,
    change `Log.level`.
 */
public class LOG
{
    
    private init()
    {
        
    }
    
    /**
        Represents the level of log statements.
     */
    public enum LogLevel: Int
    {
        /** Useful for messages that assist with debugging*/
        case debug = 1
        /** Verboce information on normal application activity*/
        case info = 2
        /** Warns of a situation or condition that needs attention, but is not show-stopping. */
        case warn = 3
        /** Warns of a situation that impacted the user's experience. */
        case error = 4
    }
    
    /**
        This is the level enabled in the Logger.
        It can be changed to [debug, info, warn, error]
     */
    public static var level = LogLevel.info
    
    
    /**
        The Archeota logger will only print messages if this flag is enabled.
     */
    #if DEBUG
        fileprivate static var debugEnabled = true
    #else
        fileprivate static var debugEnabled = false
    #endif
    
    /**
        Enables the Logger
     */
    public static func enable()
    {
        LOG.debugEnabled = true
    }
    
    /**
        Disables the Logger.
     */
    public static func disable()
    {
        LOG.debugEnabled = false
    }
    
    /**
        Check whether the Logger is enabled.
     */
    public static var isEnabled: Bool
    {
        return LOG.debugEnabled
    }
    
    //MARK: Color Output
    fileprivate static var shouldDisplayColor = false
    
    /**
        Enables color output from the console. This is useful if your XCode supports it.
    */
    public static func enableColor()
    {
        shouldDisplayColor = true
    }
    
    /**
        Disables color output from the console. Color should be disabled to if your XCode does not support color output,
        otherwise it will add noise to the log statements.
    */
    public static func disableColor()
    {
        shouldDisplayColor = false
    }
}

extension LOG
{

    /**
        Prints a Debug message.
     
        - Parameter message : The message to print
     */
    public static func debug(_ message: String, function: String = #function)
    {
        if canPrint(level: .debug)
        {
            let now = dateToString(date: Date())
            let log = "\(now) - [DEBUG] - \(function) - \(message)"
            
            noColor(log)
        }

    }
    
    /**
        Prints an Info message.
     
        - Parameter message: The message to print
     */
    public static func info(_ message: String, function: String = #function)
    {
        if canPrint(level: .info)
        {
            let now = dateToString(date: Date())
            let log = "\(now) - [INFO] - \(function) - \(message)"
            
            if shouldDisplayColor
            {
                green(log)
            }
            else
            {
                noColor(log)
            }
        }
    }
    
    /**
        Prints a Warn message.
     
        - Parameter message: The message to print
     */
    public static func warn(_ message: String, function: String = #function)
    {
        if canPrint(level: .warn)
        {
            let now = dateToString(date: Date())
            let log = "\(now) - [WARN] - \(function) - \(message)"
            
            if shouldDisplayColor
            {
                orange(log)
            }
            else
            {
                noColor(log)
            }
        }
    }
    
    /**
        Prints an Error message.
     
        - Parameter message: The message to print
     */
    public static func error(_ message: String, function: String = #function)
    {
        if canPrint(level: .warn)
        {
            let now = dateToString(date: Date())
            let log = "\(now) - [ERROR] - \(function) - \(message)"
            
            if shouldDisplayColor
            {
                red(log)
            }
            else
            {
                noColor(log)
            }
        }
    }

}

private extension LOG
{
    
    static func dateToString(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:MM:ss.sss"
        return formatter.string(from: date)
    }
    
    static func canPrint(level: LogLevel) -> Bool
    {
        return (level.rawValue >= self.level.rawValue) && isEnabled
    }
    
}

private extension LOG
{
    
    private static let ESCAPE = "\u{001b}["
    
    private static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
    private static let RESET_BG = ESCAPE + "bg;" // Clear any background color
    private static let RESET = ESCAPE + ";"   // Clear any foreground or background color
    
    static func noColor<T>(_ object: T)
    {
        print(object)
    }
    
    static func red<T>(_ object: T)
    {
        print("\(ESCAPE)fg255,0,0;\(object)\(RESET)")
    }
    
    static func green<T>(_ object: T)
    {
        print("\(ESCAPE)fg0,255,0;\(object)\(RESET)")
    }
    
    static func blue<T>(_ object: T)
    {
        print("\(ESCAPE)fg0,0,255;\(object)\(RESET)")
    }
    
    static func yellow<T>(_ object: T)
    {
        print("\(ESCAPE)fg255,255,0;\(object)\(RESET)")
    }
    
    static func purple<T>(_ object: T)
    {
        print("\(ESCAPE)fg255,0,255;\(object)\(RESET)")
    }
    
    static func cyan<T>(_ object: T)
    {
        print("\(ESCAPE)fg0,255,255;\(object)\(RESET)")
    }
    
    static func orange<T>(_ object: T)
    {
        print("\(ESCAPE)fg255,127,0;\(object)\(RESET)")
    }
}
