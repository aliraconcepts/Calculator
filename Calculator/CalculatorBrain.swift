//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by sashka on 21/09/2016.
//  Copyright © 2016 sashka. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case VariableOperand(String, Double?)
        case UnaryOperation(String, (Double) -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .VariableOperand(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    var variableValues = [String: Double]()
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    
    init()
    {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(op: Op.BinaryOperation("×", *))
        learnOp(op: Op.BinaryOperation("÷", {$1 / $0}))
        learnOp(op: Op.BinaryOperation("+", +))
        learnOp(op: Op.BinaryOperation("−", {$1 - $0}))
        learnOp(op: Op.UnaryOperation("√", sqrt))
        learnOp(op: Op.UnaryOperation("sin", sin))
        learnOp(op: Op.UnaryOperation("cos", cos))
        learnOp(op: Op.VariableOperand("π", M_PI))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        var remainingOps = ops

        if !ops.isEmpty {
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand): // when a digit is passed
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation): // when a single digit operation is passed
                let operandEvaluation = evaluate(ops: remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(ops: remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(ops: op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .VariableOperand( let keyVar, let varValue) where keyVar == "π":
                return (varValue, remainingOps)
            case .VariableOperand(let keyVar, _):
                return (variableValues[keyVar], remainingOps)
            }
        }
        return (nil, remainingOps) // if opStack is empty
    }
    
    func evalute() -> Double? {
        let (result, _) = evaluate(ops: opStack)
//        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evalute()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.VariableOperand(symbol, variableValues[symbol]))
        return evalute()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol]
        {
            opStack.append(operation)
        }
        return evalute()
    }
    
    func clearStack() {
        opStack.removeAll()
        variableValues.removeAll()
    }
    
    // Calls for the description and has some smarts about brackets.
    
    var description: String {
        get {
            let describe = stackDescribe(ops: opStack)
            if let lineFinal = describe.outputLine {
                if describe.remainingOps.isEmpty {
                    return "\(lineFinal) ="
                }
                else if let remainderLine = stackDescribe(ops: describe.remainingOps).outputLine {
                    return "\(remainderLine), \(lineFinal)"
                }
            }
            return " "
        }
    }
    
    // Outputs a readable description of the stack.
    
    private func stackDescribe(ops: [Op]) -> (outputLine: String?, remainingOps: [Op]) {
        var remainingOps = ops
        
        if !ops.isEmpty {
            let opLast = remainingOps.removeLast()
            
            switch opLast {
                
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
                
            case .BinaryOperation(let symbol, _):
                let value2 = stackDescribe(ops: remainingOps)
                
                if let v2 = value2.outputLine {
                    let value1 = stackDescribe(ops: value2.remainingOps)
                    if let v1 = value1.outputLine {
                        if symbol == v2 || value1.remainingOps.isEmpty {
                            return ("\(v1) \(symbol) \(v2)", value1.remainingOps)
                        }
                        else {
                            return ("(\(v1) \(symbol) \(v2))", value1.remainingOps)
                        }
                    }
                    else {
                        return ("? \(symbol) \(v2)", value1.remainingOps)
                    }
                }
                
            case .UnaryOperation(let symbol, _):
                let value = stackDescribe(ops: remainingOps)
                if let line = value.outputLine {
                    if line[line.startIndex] == "(" {
                        return ("\(symbol)\(line)", value.remainingOps)
                    }
                    return ("\(symbol)(\(line))", value.remainingOps)
                }
                
            case .VariableOperand(let symbol, _):
                return (symbol, remainingOps)
            }
        }
        return (nil, remainingOps) // if stack is empty
    }
}
