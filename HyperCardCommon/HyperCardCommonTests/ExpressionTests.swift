//
//  TestSchemas.swift
//  HyperCardCommonTests
//
//  Created by Pierre Lorenzi on 27/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//

import XCTest
import HyperCardCommon


/// Tests on schemas

class ExpressionTests: XCTestCase {
    
    override class func setUp() {
        
        Schemas.finalizeSchemas()
    }
    
    func testLiteral() {

        let schema = Schemas.expression

        XCTAssert(schema.parse("true") == Expression.literal(Literal.boolean(true)))
        XCTAssert(schema.parse("false") == Expression.literal(Literal.boolean(false)))
        XCTAssert(schema.parse("fàLSE") == Expression.literal(Literal.boolean(false)))
        XCTAssert(schema.parse("\"true\"") == Expression.literal(Literal.quotedString("true")))
        XCTAssert(schema.parse("\"several words\"") == Expression.literal(Literal.quotedString("several words")))
        XCTAssert(schema.parse("unquoted") == Expression.containerContent(ContainerDescriptor.variable(identifier: "unquoted")))
        XCTAssert(schema.parse("123") == Expression.literal(Literal.integer(123)))
        XCTAssert(schema.parse("00123") == Expression.literal(Literal.integer(123)))
        XCTAssert(schema.parse("123.25") == Expression.literal(Literal.realNumber(123.25)))
        XCTAssert(schema.parse("123.2500") == Expression.literal(Literal.realNumber(123.25)))
    }
    
    func testOperators() {
        
        let schema = Schemas.expression
        
        XCTAssert(schema.parse("2 + 2") == Expression.operator(Operator.addition(Expression.literal(Literal.integer(2)), Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("- 2 + 2") == Expression.operator(Operator.addition(Expression.operator(Operator.opposite(Expression.literal(Literal.integer(2)))), Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("2 * 2 + 2") == Expression.operator(Operator.addition(Expression.operator(Operator.multiplication(Expression.literal(Literal.integer(2)), Expression.literal(Literal.integer(2)))), Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("2 + 2 * 2") == Expression.operator(Operator.addition( Expression.literal(Literal.integer(2)),Expression.operator(Operator.multiplication(Expression.literal(Literal.integer(2)), Expression.literal(Literal.integer(2)))))))
        XCTAssert(schema.parse("2 + 2") == Expression.operator(Operator.addition(Expression.literal(Literal.integer(2)), Expression.literal(Literal.integer(2)))))
        
        XCTAssert(schema.parse("(2 + 2)") == Expression.operator(Operator.parentheses(Expression.operator(Operator.addition(Expression.literal(Literal.integer(2)), Expression.literal(Literal.integer(2)))))))
        XCTAssert(schema.parse("not true") == Expression.operator(Operator.not(Expression.literal(Literal.boolean(true)))))
        XCTAssert(schema.parse("a&&b") == Expression.operator(Operator.concatenationWithSpace(Expression.containerContent(ContainerDescriptor.variable(identifier: "a")), Expression.containerContent(ContainerDescriptor.variable(identifier: "b")))))
        
    }
    
    func testFunctions() {
        
        let schema = Schemas.expression
        
        XCTAssert(schema.parse("the target") == Expression.functionCall(FunctionCall.target(exactness: nil)))
        XCTAssert(schema.parse("target") != Expression.functionCall(FunctionCall.target(exactness: nil)))
        XCTAssert(schema.parse("the long target") == Expression.functionCall(FunctionCall.target(exactness: Exactness.long)))
        XCTAssert(schema.parse("the abbr target") == Expression.functionCall(FunctionCall.target(exactness: Exactness.abbreviated)))
        XCTAssert(schema.parse("the short target") == Expression.functionCall(FunctionCall.target(exactness: Exactness.short)))
        XCTAssert(schema.parse("the exp of 2") == Expression.functionCall(FunctionCall.exp(Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("exp of 2") == Expression.functionCall(FunctionCall.exp(Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("exp(2)") == Expression.functionCall(FunctionCall.exp(Expression.literal(Literal.integer(2)))))
        XCTAssert(schema.parse("coucou()") == Expression.functionCall(FunctionCall.custom(identifier: "coucou", arguments: nil)))
        XCTAssert(schema.parse("coucou(2.0)") == Expression.functionCall(FunctionCall.custom(identifier: "coucou", arguments: [Expression.literal(Literal.realNumber(2.0))])))
        XCTAssert(schema.parse("coucou(2.0, 3.0)") == Expression.functionCall(FunctionCall.custom(identifier: "coucou", arguments: [Expression.literal(Literal.realNumber(2.0)),Expression.literal(Literal.realNumber(3.0))])))
        XCTAssert(schema.parse("coucou(2.0,3.0,4.0)") == Expression.functionCall(FunctionCall.custom(identifier: "coucou", arguments: [Expression.literal(Literal.realNumber(2.0)),Expression.literal(Literal.realNumber(3.0)),Expression.literal(Literal.realNumber(4.0))])))
        XCTAssert(schema.parse("coucou(2.0,3.0,4.0, \"coucou\")") == Expression.functionCall(FunctionCall.custom(identifier: "coucou", arguments: [Expression.literal(Literal.realNumber(2.0)),Expression.literal(Literal.realNumber(3.0)),Expression.literal(Literal.realNumber(4.0)), Expression.literal(Literal.quotedString("coucou"))])))
        XCTAssert(schema.parse("the coucou of 2.0") == nil)
    }
    
    func testContainers() {
        
        let schema = Schemas.expression
        
        XCTAssert(schema.parse("the message box") == Expression.containerContent(ContainerDescriptor.messageBox))
        XCTAssert(schema.parse("message box") == Expression.containerContent(ContainerDescriptor.messageBox))
        XCTAssert(schema.parse("msg box") == Expression.containerContent(ContainerDescriptor.messageBox))
        XCTAssert(schema.parse("the selection") == Expression.containerContent(ContainerDescriptor.selection))
        XCTAssert(schema.parse("selection") == Expression.containerContent(ContainerDescriptor.selection))
        XCTAssert(schema.parse("coucou") == Expression.containerContent(ContainerDescriptor.variable(identifier: "coucou")))
    }
    
    func testParts() {
        
        let schema = Schemas.expression
        
        XCTAssert(schema.parse("card field id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("card field 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withOrdinal(Ordinal.number(Expression.literal(Literal.integer(3)))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("card field coucou") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withOrdinal(Ordinal.number(Expression.containerContent(ContainerDescriptor.variable(identifier: "coucou")))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("card field id") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withOrdinal(Ordinal.number(Expression.containerContent(ContainerDescriptor.variable(identifier: "id")))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("card field \"coucou\"") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withName(Expression.literal(Literal.quotedString("coucou"))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("cd fld id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("field id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.background, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("background field id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.field, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.background, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("card button id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.button, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("button id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.button, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("card part id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.part, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("part id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.part, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.card, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
        XCTAssert(schema.parse("bg part id 3") == Expression.containerContent(ContainerDescriptor.part(PartDescriptor(type: PartDescriptorType.part, typedPartDescriptor: TypedPartDescriptor(layer: LayerType.background, identification: HyperCardObjectIdentification.withIdentifier(Expression.literal(Literal.integer(3))), card: CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil))))))
    }
    
    func testChunks() {
        
        let schema = Schemas.expression
        
        XCTAssert(schema.parse("char 2 of \"aaa\"") == Expression.chunk(ChunkExpression(expression: Expression.literal(Literal.quotedString("aaa")), chunk: Chunk(elements: [ChunkElement(type: ChunkType.character, number: ChunkNumber.single(Ordinal.number(Expression.literal(Literal.integer(2)))))]))))
    }
    
}
