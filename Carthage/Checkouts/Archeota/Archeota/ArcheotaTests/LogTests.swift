//
//  ArcheotaTests.swift
//  ArcheotaTests
//
//  Created by Wellington Moreno on 8/27/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import XCTest
@testable import Archeota

class LogTests: XCTestCase
{
    
    private let message = "some really long message here that I am using to test the library and the logging functionality"
    
    override func setUp()
    {
        super.setUp()
        
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDebug()
    {
        LOG.debug(message)
    }
    
    func testInfo()
    {
        LOG.info(message)
    }
    
    func testWarn()
    {
        
        LOG.warn(message)
    }
    
    func testError()
    {
        LOG.error(message)
    }
    
    func testEnable()
    {
        LOG.enable()
        XCTAssert(LOG.isEnabled)
    }
    
    func testDisable()
    {
        LOG.disable()
        XCTAssert(!LOG.isEnabled)
    }
    
}
