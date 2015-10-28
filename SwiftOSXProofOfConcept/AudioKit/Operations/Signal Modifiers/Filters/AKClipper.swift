//
//  AKClipper.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** Applies clip-limiting to a signal

Clips a signal to a predefined limit, in a "soft" manner, using one of three methods.
*/
@objc class AKClipper : AKParameter {

    // MARK: - Properties

    private var clip = UnsafeMutablePointer<sp_clip>.alloc(1)
    private var clip2 = UnsafeMutablePointer<sp_clip>.alloc(1)

    private var input = AKParameter()

    /** Method of clipping. 0 = Bram de Jong, 1 = Sine, 2 = tanh. [Default Value: 0] */
    private var method: Int32 = 0

    /** Threshold / limiting value. [Default Value: 1.0] */
    private var limit: Float = 0


    /** When meth is 0 (Bram De Jong), indicates point at which clipping starts in the range 0-1. [Default Value: 0.5] */
    var clippingStartPoint: AKParameter = akp(0.5) {
        didSet {
            clippingStartPoint.bind(&clip.memory.arg, right:&clip2.memory.arg)
            dependencies.append(clippingStartPoint)
        }
    }


    // MARK: - Initializers

    /** Instantiates the clipper with default values

    - parameter input: Input audio signal. 
    */
    init(_ input: AKParameter)
    {
        super.init()
        self.input = input
        setup()
        dependencies = [input]
        bindAll()
    }

    /** Instantiates clipper with constants

    - parameter input: Input audio signal. 
    - parameter method: Method of clipping. 0 = Bram de Jong, 1 = Sine, 2 = tanh. [Default Value: 0]
    - parameter limit: Threshold / limiting value. [Default Value: 1.0]
    */
    init (_ input: AKParameter, method: Int32, limit: Float) {
        super.init()
        self.input = input
        setup(method, limit: limit)
        dependencies = [input]
        bindAll()
    }

    /** Instantiates the clipper with all values

    - parameter input: Input audio signal. 
    - parameter clippingStartPoint: When meth is 0 (Bram De Jong), indicates point at which clipping starts in the range 0-1. [Default Value: 0.5]
    - parameter method: Method of clipping. 0 = Bram de Jong, 1 = Sine, 2 = tanh. [Default Value: 0]
    - parameter limit: Threshold / limiting value. [Default Value: 1.0]
    */
    convenience init(
        _ input:            AKParameter,
        clippingStartPoint: AKParameter,
        method:             Int32,
        limit:              Float)
    {
        self.init(input, method: method, limit: limit)
        self.clippingStartPoint = clippingStartPoint

        bindAll()
    }

    // MARK: - Internals

    /** Bind every property to the internal clipper */
    internal func bindAll() {
        clippingStartPoint.bind(&clip.memory.arg, right:&clip2.memory.arg)
        dependencies.append(clippingStartPoint)
    }

    /** Internal set up function */
    internal func setup(method: Int32 = 0, limit: Float = 1.0) {
        sp_clip_create(&clip)
        sp_clip_create(&clip2)
        sp_clip_init(AKManager.sharedManager.data, clip, method, limit)
        sp_clip_init(AKManager.sharedManager.data, clip2, method, limit)
    }

    /** Computation of the next value */
    override func compute() {
        sp_clip_compute(AKManager.sharedManager.data, clip, &(input.leftOutput), &leftOutput);
        sp_clip_compute(AKManager.sharedManager.data, clip2, &(input.rightOutput), &rightOutput);
    }

    /** Release of memory */
    override func teardown() {
        sp_clip_destroy(&clip)
        sp_clip_destroy(&clip2)
    }
}