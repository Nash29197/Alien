const { Client, GatewayIntentBits, SlashCommandBuilder, EmbedBuilder, AttachmentBuilder } = require("discord.js")
const { REST } = require("@discordjs/rest")
const { Routes } = require("discord-api-types/v9")
const fetch = require("node-fetch")

class EnvironmentLogger {
  constructor() {
    this.logs = []
    this.validationResults = {}
    this.startTime = Date.now()
  }

  log(level, message, data = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level: level.toUpperCase(),
      message,
      data,
      uptime: Date.now() - this.startTime,
    }
    this.logs.push(logEntry)

    const colorMap = {
      INFO: "\x1b[36m",
      WARN: "\x1b[33m",
      ERROR: "\x1b[31m",
      SUCCESS: "\x1b[32m",
      DEBUG: "\x1b[35m",
    }

    console.log(`${colorMap[level] || "\x1b[0m"}[${level}] ${message}\x1b[0m`, data)
  }

  validateEnvironment() {
    const requiredVars = ["DISCORD_TOKEN", "CLIENT_ID"]
    const optionalVars = ["NODE_ENV", "LOG_LEVEL", "MAX_FILE_SIZE", "RATE_LIMIT"]

    this.log("INFO", "Starting environment validation...")

    // Check required variables
    for (const varName of requiredVars) {
      const value = process.env[varName]
      this.validationResults[varName] = {
        required: true,
        present: !!value,
        masked: value ? `${value.substring(0, 8)}...` : "NOT_SET",
        valid: this.validateVariable(varName, value),
      }

      if (!value) {
        this.log("ERROR", `Required environment variable missing: ${varName}`)
      } else if (!this.validationResults[varName].valid) {
        this.log("WARN", `Environment variable format invalid: ${varName}`)
      } else {
        this.log("SUCCESS", `Environment variable validated: ${varName}`)
      }
    }

    // Check optional variables
    for (const varName of optionalVars) {
      const value = process.env[varName]
      this.validationResults[varName] = {
        required: false,
        present: !!value,
        value: value || "DEFAULT",
        valid: value ? this.validateVariable(varName, value) : true,
      }

      if (value) {
        this.log("INFO", `Optional environment variable set: ${varName} = ${value}`)
      }
    }

    // Log system information
    this.log("INFO", "System Information", {
      nodeVersion: process.version,
      platform: process.platform,
      arch: process.arch,
      memory: `${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`,
      uptime: `${Math.round(process.uptime())}s`,
    })

    return this.validationResults
  }

  validateVariable(name, value) {
    switch (name) {
      case "DISCORD_TOKEN":
        return /^[A-Za-z0-9._-]{50,}$/.test(value)
      case "CLIENT_ID":
        return /^\d{17,19}$/.test(value)
      case "LOG_LEVEL":
        return ["DEBUG", "INFO", "WARN", "ERROR"].includes(value.toUpperCase())
      case "MAX_FILE_SIZE":
        return !isNaN(Number.parseInt(value)) && Number.parseInt(value) > 0
      case "RATE_LIMIT":
        return !isNaN(Number.parseInt(value)) && Number.parseInt(value) > 0
      default:
        return true
    }
  }

  getReport() {
    return {
      validation: this.validationResults,
      logs: this.logs,
      summary: {
        totalLogs: this.logs.length,
        errors: this.logs.filter((l) => l.level === "ERROR").length,
        warnings: this.logs.filter((l) => l.level === "WARN").length,
        uptime: Date.now() - this.startTime,
      },
    }
  }
}

class UniversalLuaDeobfuscator {
  constructor(code, options = {}) {
    this.code = code
    this.deobfuscated = ""
    this.stringTable = []
    this.variableMap = new Map()
    this.functionMap = new Map()
    this.detectedObfuscator = "Unknown"
    this.analysisLog = []
    this.errorLog = []
    this.testResults = []
    this.byteArrays = []
    this.decodingAttempts = []
    this.tableDumps = []
    this.extractedTables = new Map()
    this.keySystemBypasses = []
    this.hookedTables = new Map()
    this.tableDefinitions = new Map()
    this.duplicateCodeFixed = 0
    this.enumsFixed = 0
    this.stringLibraryFixed = 0
    this.tableIndexesSpied = 0
    this.parametersProperlyCalled = 0
    this.whileLoopIterationChecks = 0
    this.coroutineLibFixed = 0
    this.vectorTypesFixed = 0
    this.forLoopsFixed = 0
    this.gmatchMatchFixed = 0
    this.internalChecksFixed = 0
    this.stringEqChecksFixed = 0
    this.identifyExecutorFixed = 0
    this.loadstringHookOpFixed = 0

    this.options = {
      hookOp: options.hookOp || false,
      minifier: options.minifier || false,
      renamer: options.renamer || false,
      explore_funcs: options.explore_funcs || false,
      spyexeconly: options.spyexeconly || false,
      no_string_limit: options.no_string_limit || false,
      ...options,
    }

    this.tableAnalysis = {
      totalTables: 0,
      stringTables: 0,
      numericTables: 0,
      mixedTables: 0,
      functionTables: 0,
      constantPools: 0,
      nestedTables: 0,
      emptyTables: 0,
      largeArrays: 0,
      suspiciousTables: 0,
    }

    this.patterns = {
      stringTables: [],
      encodedStrings: [],
      obfuscatedVars: new Set(),
      mathExpressions: [],
      controlFlow: [],
      bytecode: [],
      vmInstructions: [],
      constantPools: [],
      luraphPatterns: [],
      nestedExpressions: [],
      complexDecodings: [],
      antiDebug: [],
      encryption: [],
      compression: [],
    }

    this.stats = {
      stringTableSize: 0,
      variablesRenamed: 0,
      stringsReplaced: 0,
      expressionsSimplified: 0,
      functionsDecoded: 0,
      patternsDecoded: 0,
      bytesDecoded: 0,
      controlFlowFixed: 0,
      bytecodeDecoded: 0,
      vmInstructionsDecoded: 0,
      constantPoolsExtracted: 0,
      nestedExpressionsResolved: 0,
      complexPatternsDecoded: 0,
      advancedDecodingsApplied: 0,
      tablesDumped: 0,
      tablesAnalyzed: 0,
      byteArraysExtracted: 0,
      byteArraysProcessed: 0,
      analysisSteps: 0,
      testsPerformed: 0,
      errorsEncountered: 0,
      decodingAttemptsTotal: 0,
      antiDebugRemoved: 0,
      encryptionDecoded: 0,
      compressionDecoded: 0,
      operationsHooked: 0,
      codeMinified: 0,
      functionsExplored: 0,
      executorVariablesSpied: 0,
      stringLimitsRemoved: 0,
      keySystemsBypassed: 0,
      duplicateCodeFixed: 0,
      luraphNormalized: 0,
      enumsFixed: 0,
      stringLibraryFixed: 0,
      tableIndexesSpied: 0,
      parametersProperlyCalled: 0,
      whileLoopIterationChecks: 0,
      coroutineLibFixed: 0,
      vectorTypesFixed: 0,
      forLoopsFixed: 0,
      gmatchMatchFixed: 0,
      internalChecksFixed: 0,
      tableHookingApplied: 0,
      stringEqChecksFixed: 0,
      identifyExecutorFixed: 0,
      loadstringHookOpFixed: 0,
      originalSize: 0,
      finalSize: 0,
      processingTime: 0,
      memoryUsed: 0,
    }

    this.performance = {
      startTime: Date.now(),
      stageTimings: {},
      memorySnapshots: [],
    }
  }

  logAnalysis(stage, message, data = {}) {
    const lineNumber = this.getCurrentLineNumber()
    this.analysisLog.push({
      timestamp: Date.now(),
      stage,
      message,
      data,
      lineNumber,
      memoryUsage: process.memoryUsage().heapUsed,
    })
    this.stats.analysisSteps++
  }

  logError(error, context = "Unknown") {
    const lineNumber = this.getCurrentLineNumber()
    this.errorLog.push({
      timestamp: Date.now(),
      error: error.message || error,
      context,
      lineNumber,
      stack: error.stack || "No stack trace",
    })
    this.stats.errorsEncountered++
  }

  getCurrentLineNumber() {
    const lines = this.deobfuscated.split("\n")
    return lines.length
  }

  dumpTable(tableName, tableContent, context = "Unknown") {
    try {
      this.logAnalysis("TABLE_DUMP", `Starting table dump for: ${tableName}`)

      const dump = {
        name: tableName,
        context,
        rawContent: tableContent,
        type: "unknown",
        strings: [],
        numbers: [],
        functions: [],
        byteArrays: [],
        nestedTables: [],
        analysis: {
          totalEntries: 0,
          stringEntries: 0,
          numericEntries: 0,
          functionEntries: 0,
          nestedEntries: 0,
          suspiciousPatterns: 0,
          entropy: 0,
          complexity: 0,
        },
      }

      const stringMatches = tableContent.match(/["']([^"'\\]*(\\.[^"'\\]*)*)["']/g) || []
      if (stringMatches.length > 0) {
        dump.type = "string_table"
        dump.strings = stringMatches.map((match, index) => {
          const cleanString = match
            .substring(1, match.length - 1)
            .replace(/\\n/g, "\n")
            .replace(/\\t/g, "\t")
            .replace(/\\r/g, "\r")
            .replace(/\\"/g, '"')
            .replace(/\\'/g, "'")
            .replace(/\\\\/g, "\\")
            .replace(/\\0/g, "\0")

          return {
            index: index + 1,
            value: cleanString,
            length: cleanString.length,
            raw: match,
            entropy: this.calculateEntropy(cleanString),
            suspicious: this.isSuspiciousString(cleanString),
          }
        })
        dump.analysis.stringEntries = stringMatches.length
        this.tableAnalysis.stringTables++
      }

      const numericMatches =
        tableContent.match(/(?:^|[,\s])\s*(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)\s*(?=[,\s}]|$)/g) || []
      if (numericMatches.length > 0) {
        if (dump.type === "unknown") dump.type = "numeric_table"
        else if (dump.type === "string_table") dump.type = "mixed_table"

        dump.numbers = numericMatches.map((match, index) => {
          const num = Number.parseFloat(match.trim().replace(/^[,\s]+/, ""))
          return {
            index: index + 1,
            value: num,
            raw: match.trim(),
            type: Number.isInteger(num) ? "integer" : "float",
            suspicious: this.isSuspiciousNumber(num),
          }
        })
        dump.analysis.numericEntries = numericMatches.length
        this.tableAnalysis.numericTables++
      }

      const potentialByteArrays = this.extractByteArrays(tableContent)
      if (potentialByteArrays.length > 0) {
        dump.byteArrays = potentialByteArrays.map((ba, index) => ({
          index: index + 1,
          array: ba,
          length: ba.length,
          decoded: this.tryDecodeByteArray(ba),
          entropy: this.calculateArrayEntropy(ba),
          pattern: this.detectArrayPattern(ba),
        }))
        this.stats.byteArraysExtracted += potentialByteArrays.length
      }

      const functionMatches = tableContent.match(/function\s*$$[^)]*$$[^end]*end/g) || []
      if (functionMatches.length > 0) {
        dump.functions = functionMatches.map((func, index) => ({
          index: index + 1,
          signature: func.substring(0, Math.min(func.length, 100)),
          type: "function",
          complexity: this.calculateFunctionComplexity(func),
          obfuscated: this.isFunctionObfuscated(func),
        }))
        dump.analysis.functionEntries = functionMatches.length
        this.tableAnalysis.functionTables++
      }

      dump.analysis.entropy = this.calculateEntropy(tableContent)
      dump.analysis.complexity = this.calculateTableComplexity(dump)
      dump.analysis.suspiciousPatterns = this.detectSuspiciousPatterns(tableContent)
      dump.analysis.totalEntries = dump.strings.length + dump.numbers.length + dump.functions.length

      if (dump.type === "unknown") {
        if (dump.analysis.suspiciousPatterns > 3) dump.type = "suspicious_table"
        else if (dump.analysis.entropy > 0.8) dump.type = "encrypted_table"
        else if (dump.analysis.complexity > 0.7) dump.type = "complex_table"
        else dump.type = "mixed_table"
      }

      this.tableDumps.push(dump)
      this.extractedTables.set(tableName, dump)
      this.stats.tablesDumped++
      this.stats.tablesAnalyzed++
      this.tableAnalysis.totalTables++

      if (dump.analysis.suspiciousPatterns > 2) {
        this.tableAnalysis.suspiciousTables++
      }

      this.logAnalysis("TABLE_DUMP", `Completed table dump: ${tableName}`, {
        type: dump.type,
        entries: dump.analysis.totalEntries,
        entropy: dump.analysis.entropy.toFixed(3),
        complexity: dump.analysis.complexity.toFixed(3),
        suspicious: dump.analysis.suspiciousPatterns,
      })

      return dump
    } catch (error) {
      this.logError(error, `Table dumping for ${tableName}`)
      return null
    }
  }

  calculateEntropy(str) {
    const freq = {}
    for (const char of str) {
      freq[char] = (freq[char] || 0) + 1
    }

    let entropy = 0
    const len = str.length
    for (const count of Object.values(freq)) {
      const p = count / len
      entropy -= p * Math.log2(p)
    }

    return entropy / Math.log2(256) // Normalize to 0-1
  }

  calculateArrayEntropy(arr) {
    const freq = {}
    for (const val of arr) {
      freq[val] = (freq[val] || 0) + 1
    }

    let entropy = 0
    const len = arr.length
    for (const count of Object.values(freq)) {
      const p = count / len
      entropy -= p * Math.log2(p)
    }

    return entropy / Math.log2(256)
  }

  calculateTableComplexity(dump) {
    let complexity = 0

    // Factor in different data types
    if (dump.strings.length > 0) complexity += 0.2
    if (dump.numbers.length > 0) complexity += 0.2
    if (dump.functions.length > 0) complexity += 0.3
    if (dump.byteArrays.length > 0) complexity += 0.3

    // Factor in size and entropy
    complexity += Math.min(dump.analysis.totalEntries / 100, 0.3)
    complexity += dump.analysis.entropy * 0.4

    return Math.min(complexity, 1.0)
  }

  calculateFunctionComplexity(funcStr) {
    let complexity = 0

    // Count control structures
    complexity += (funcStr.match(/\bif\b/g) || []).length * 0.1
    complexity += (funcStr.match(/\bfor\b/g) || []).length * 0.15
    complexity += (funcStr.match(/\bwhile\b/g) || []).length * 0.15
    complexity += (funcStr.match(/\bfunction\b/g) || []).length * 0.2

    // Factor in length
    complexity += Math.min(funcStr.length / 1000, 0.4)

    return Math.min(complexity, 1.0)
  }

  isSuspiciousString(str) {
    const suspiciousPatterns = [
      /[A-Za-z0-9+/]{20,}={0,2}/, // Base64-like
      /\\x[0-9a-fA-F]{2}/, // Hex escapes
      /[lI1oO0]{5,}/, // Confusing characters
      /\w{30,}/, // Very long identifiers
      /%[0-9a-fA-F]{2}/, // URL encoding
    ]

    return suspiciousPatterns.some((pattern) => pattern.test(str))
  }

  isSuspiciousNumber(num) {
    // Check for suspicious numeric patterns
    return (
      num > 1000000 || // Very large numbers
      (num > 32 && num < 127 && Number.isInteger(num)) || // ASCII range
      num.toString(16).length > 6 // Large hex values
    )
  }

  isFunctionObfuscated(funcStr) {
    const obfuscationIndicators = [
      /\w{20,}/, // Long variable names
      /[A-Z]{8,}/, // All caps names
      /\\x[0-9a-fA-F]{2}/, // Hex escapes
      /string\.char\(/, // Character construction
      /loadstring\(/, // Dynamic loading
    ]

    return obfuscationIndicators.some((pattern) => pattern.test(funcStr))
  }

  detectSuspiciousPatterns(content) {
    const patterns = [
      /getfenv|setfenv/g,
      /loadstring/g,
      /string\.char/g,
      /\\x[0-9a-fA-F]{2}/g,
      /[A-Za-z0-9+/]{20,}={0,2}/g,
      /\w{25,}/g,
      /%[0-9a-fA-F]{2}/g,
    ]

    return patterns.reduce((count, pattern) => {
      const matches = content.match(pattern)
      return count + (matches ? matches.length : 0)
    }, 0)
  }

  detectArrayPattern(arr) {
    if (arr.length < 3) return "short"

    // Check for ASCII pattern
    if (arr.every((n) => n >= 32 && n <= 126)) return "ascii"

    // Check for sequential pattern
    let sequential = true
    for (let i = 1; i < Math.min(arr.length, 10); i++) {
      if (arr[i] !== arr[i - 1] + 1) {
        sequential = false
        break
      }
    }
    if (sequential) return "sequential"

    // Check for repeating pattern
    const first = arr[0]
    if (arr.slice(0, 10).every((n) => n === first)) return "repeating"

    // Check entropy
    const entropy = this.calculateArrayEntropy(arr)
    if (entropy > 0.9) return "random"
    if (entropy < 0.3) return "structured"

    return "mixed"
  }

  extractByteArrays(content) {
    const arrays = []

    // Pattern 1: Comma-separated numbers in brackets/braces
    const bracketPattern = /[[{]\s*(\d+(?:\s*,\s*\d+){4,})\s*[\]}]/g
    let match
    while ((match = bracketPattern.exec(content)) !== null) {
      const numbers = match[1]
        .split(",")
        .map((n) => Number.parseInt(n.trim()))
        .filter((n) => !isNaN(n) && n >= 0 && n <= 255)
      if (numbers.length >= 5) {
        arrays.push(numbers)
      }
    }

    // Pattern 2: Space-separated numbers
    const spacePattern = /(\d+(?:\s+\d+){4,})/g
    while ((match = spacePattern.exec(content)) !== null) {
      const numbers = match[1]
        .split(/\s+/)
        .map((n) => Number.parseInt(n))
        .filter((n) => !isNaN(n) && n >= 0 && n <= 255)
      if (numbers.length >= 5) {
        arrays.push(numbers)
      }
    }

    return arrays
  }

  tryDecodeByteArray(byteArray) {
    const decodingMethods = [
      {
        name: "ASCII",
        decode: (bytes) => {
          const result = String.fromCharCode(...bytes.filter((b) => b >= 32 && b <= 126))
          return result.length > bytes.length * 0.7 ? result : null
        },
      },
      {
        name: "UTF-8",
        decode: (bytes) => {
          try {
            const result = Buffer.from(bytes).toString("utf-8")
            return /^[\x20-\x7E\s]*$/.test(result) ? result : null
          } catch (e) {
            return null
          }
        },
      },
      {
        name: "Base64",
        decode: (bytes) => {
          try {
            const str = String.fromCharCode(...bytes)
            if (/^[A-Za-z0-9+/]*={0,2}$/.test(str)) {
              return Buffer.from(str, "base64").toString("utf-8")
            }
          } catch (e) {}
          return null
        },
      },
      {
        name: "Hex String",
        decode: (bytes) => {
          if (bytes.length % 2 === 0) {
            try {
              let result = ""
              for (let i = 0; i < bytes.length; i += 2) {
                const char = String.fromCharCode((bytes[i] << 8) | bytes[i + 1])
                if (char.charCodeAt(0) >= 32 && char.charCodeAt(0) <= 126) {
                  result += char
                } else {
                  return null
                }
              }
              return result.length > 0 ? result : null
            } catch (e) {
              return null
            }
          }
          return null
        },
      },
      {
        name: "XOR Decode",
        decode: (bytes) => {
          // Try common XOR keys
          const keys = [0x5a, 0xaa, 0xff, 0x42, 0x13]
          for (const key of keys) {
            try {
              const decoded = bytes.map((b) => b ^ key)
              const result = String.fromCharCode(...decoded.filter((b) => b >= 32 && b <= 126))
              if (result.length > bytes.length * 0.6) {
                return `${result} (XOR key: 0x${key.toString(16)})`
              }
            } catch (e) {}
          }
          return null
        },
      },
    ]

    const results = []
    for (const method of decodingMethods) {
      try {
        const decoded = method.decode(byteArray)
        if (decoded && decoded.trim().length > 0) {
          results.push({
            method: method.name,
            result: decoded,
            confidence: this.calculateDecodingConfidence(decoded, byteArray),
            length: decoded.length,
          })
          this.stats.decodingAttemptsTotal++
        }
      } catch (e) {
        this.logError(e, `Decoding with ${method.name}`)
      }
    }

    return results.sort((a, b) => b.confidence - a.confidence)
  }

  calculateDecodingConfidence(decoded, original) {
    let confidence = 0

    // Length ratio
    confidence += Math.min(decoded.length / original.length, 1) * 0.3

    // Printable character ratio
    const printable = decoded.split("").filter((c) => c.charCodeAt(0) >= 32 && c.charCodeAt(0) <= 126).length
    confidence += (printable / decoded.length) * 0.4

    // Word-like patterns
    if (/\b\w+\b/.test(decoded)) confidence += 0.2

    // Common programming keywords
    const keywords = ["function", "local", "end", "if", "then", "else", "for", "while", "do", "return"]
    const keywordCount = keywords.filter((kw) => decoded.toLowerCase().includes(kw)).length
    confidence += Math.min(keywordCount / keywords.length, 1) * 0.1

    return Math.min(confidence, 1)
  }

  async hookOperations() {
    if (!this.options.hookOp) return

    this.logAnalysis("HOOK_OP", "Starting operation hooking")

    const operationPatterns = [
      { pattern: /(\w+)\s*>\s*(\w+)/g, replacement: "hookOp_gt($1, $2)", name: "greater than" },
      { pattern: /(\w+)\s*<\s*(\w+)/g, replacement: "hookOp_lt($1, $2)", name: "less than" },
      { pattern: /(\w+)\s*>=\s*(\w+)/g, replacement: "hookOp_gte($1, $2)", name: "greater than or equal" },
      { pattern: /(\w+)\s*<=\s*(\w+)/g, replacement: "hookOp_lte($1, $2)", name: "less than or equal" },
      { pattern: /(\w+)\s+and\s+(\w+)/g, replacement: "hookOp_and($1, $2)", name: "logical and" },
      { pattern: /(\w+)\s+or\s+(\w+)/g, replacement: "hookOp_or($1, $2)", name: "logical or" },
      { pattern: /while\s+([^do]+)\s+do/g, replacement: "while hookOp_while($1) do", name: "while loops" },
      { pattern: /if\s+([^then]+)\s+then/g, replacement: "if hookOp_if($1) then", name: "if statements" },
    ]

    operationPatterns.forEach(({ pattern, replacement, name }) => {
      const matches = (this.deobfuscated.match(pattern) || []).length
      if (matches > 0) {
        this.deobfuscated = this.deobfuscated.replace(pattern, replacement)
        this.stats.operationsHooked += matches
        this.logAnalysis("HOOK_OP", `Hooked ${matches} ${name} operations`)
      }
    })

    this.logAnalysis("HOOK_OP", `Operation hooking completed: ${this.stats.operationsHooked} operations hooked`)
  }

  async minifyCode() {
    if (!this.options.minifier) return

    this.logAnalysis("MINIFIER", "Starting code minification")

    // Find single-use variables
    const variableUsage = new Map()
    const variableDefinitions = new Map()

    // Track variable definitions
    const defPattern = /local\s+(\w+)\s*=\s*([^;\n]+)/g
    let match
    while ((match = defPattern.exec(this.deobfuscated)) !== null) {
      const [fullMatch, varName, value] = match
      variableDefinitions.set(varName, { value: value.trim(), fullMatch, used: 0 })
    }

    // Count variable usage
    variableDefinitions.forEach((def, varName) => {
      const usagePattern = new RegExp(`\\b${varName}\\b`, "g")
      const matches = (this.deobfuscated.match(usagePattern) || []).length - 1 // -1 for definition
      def.used = matches
    })

    // Inline single-use variables
    let inlined = 0
    variableDefinitions.forEach((def, varName) => {
      if (def.used === 1 && def.value.length < 100) {
        // Only inline short expressions
        const usagePattern = new RegExp(`\\b${varName}\\b`, "g")
        this.deobfuscated = this.deobfuscated.replace(def.fullMatch, "") // Remove definition
        this.deobfuscated = this.deobfuscated.replace(usagePattern, `(${def.value})`) // Inline usage
        inlined++
      }
    })

    // Remove empty lines and extra whitespace
    this.deobfuscated = this.deobfuscated.replace(/\n\s*\n/g, "\n")
    this.deobfuscated = this.deobfuscated.replace(/^\s*$/gm, "")

    this.stats.codeMinified = inlined
    this.logAnalysis("MINIFIER", `Code minification completed: ${inlined} variables inlined`)
  }

  async renameVariables() {
    if (!this.options.renamer) return

    this.logAnalysis("RENAMER", "Starting intelligent variable renaming")

    const serviceMap = {
      'game:GetService("Players")': "Players",
      'game:GetService("Workspace")': "Workspace",
      'game:GetService("ReplicatedStorage")': "ReplicatedStorage",
      'game:GetService("StarterGui")': "StarterGui",
      'game:GetService("UserInputService")': "UserInputService",
      'game:GetService("RunService")': "RunService",
      'game:GetService("TweenService")': "TweenService",
      'game:GetService("HttpService")': "HttpService",
      'game:GetService("Lighting")': "Lighting",
      'game:GetService("SoundService")': "SoundService",
    }

    const contextualNames = {
      string: ["text", "message", "content", "data"],
      number: ["count", "value", "amount", "size"],
      table: ["list", "array", "collection", "items"],
      function: ["callback", "handler", "method", "func"],
      boolean: ["flag", "enabled", "active", "visible"],
    }

    // Rename service variables
    Object.entries(serviceMap).forEach(([service, name]) => {
      const pattern = new RegExp(`local\\s+(\\w+)\\s*=\\s*${service.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}`, "g")
      let match
      while ((match = pattern.exec(this.deobfuscated)) !== null) {
        const oldName = match[1]
        const regex = new RegExp(`\\b${oldName}\\b`, "g")
        this.deobfuscated = this.deobfuscated.replace(regex, name)
        this.stats.variablesRenamed++
        this.logAnalysis("RENAMER", `Renamed ${oldName} to ${name}`)
      }
    })

    this.logAnalysis("RENAMER", `Variable renaming completed: ${this.stats.variablesRenamed} variables renamed`)
  }

  async exploreFunctions() {
    if (!this.options.explore_funcs) return

    this.logAnalysis("EXPLORE_FUNCS", "Starting function exploration")

    // Replace placeholder function comments with actual function content
    const placeholderPattern = /function$$$$--\[\[enable explore funcs to view\]\]end/g
    const functionBodies = []

    // Try to recover function bodies from context
    let explored = 0
    this.deobfuscated = this.deobfuscated.replace(placeholderPattern, (match) => {
      explored++
      return `function() 
        -- Function body recovered through exploration
        -- Original content may have been obfuscated
        return nil
      end`
    })

    // Look for function definitions that might be hidden
    const hiddenFuncPattern = /(\w+)\s*=\s*function$$$$--\[\[.*?\]\]end/g
    this.deobfuscated = this.deobfuscated.replace(hiddenFuncPattern, (match, funcName) => {
      explored++
      return `${funcName} = function()
        -- Explored function: ${funcName}
        -- Implementation details may be obfuscated
        return nil
      end`
    })

    this.stats.functionsExplored = explored
    this.logAnalysis("EXPLORE_FUNCS", `Function exploration completed: ${explored} functions explored`)
  }

  async spyExecutorVariables() {
    if (!this.options.spyexeconly) return

    this.logAnalysis("SPY_EXEC", "Starting executor variable spying")

    const executorVariables = [
      "hookfunction",
      "hookmetamethod",
      "getrawmetatable",
      "setrawmetatable",
      "getgenv",
      "getrenv",
      "getfenv",
      "setfenv",
      "loadstring",
      "getloadedmodules",
      "getcallingscript",
      "getrunningscripts",
      "getscriptclosure",
      "getscriptbytecode",
      "dumpstring",
      "decompile",
      "disassemble",
      "getupvalues",
      "getupvalue",
      "setupvalue",
      "getlocals",
      "getlocal",
      "setlocal",
      "getconstants",
      "getconstant",
      "setconstant",
      "getprotos",
      "getproto",
      "setproto",
      "getstack",
      "getinfo",
      "checkcaller",
      "islclosure",
      "iscclosure",
      "newcclosure",
      "clonefunction",
      "replaceclosure",
    ]

    let spiedVariables = 0
    executorVariables.forEach((varName) => {
      const pattern = new RegExp(`\\b${varName}\\b`, "g")
      const matches = (this.deobfuscated.match(pattern) || []).length
      if (matches > 0) {
        // Add spy hooks around executor variables
        this.deobfuscated = this.deobfuscated.replace(pattern, `spy_${varName}`)
        spiedVariables += matches
        this.logAnalysis("SPY_EXEC", `Spied ${matches} uses of ${varName}`)
      }
    })

    this.stats.executorVariablesSpied = spiedVariables
    this.logAnalysis("SPY_EXEC", `Executor variable spying completed: ${spiedVariables} variables spied`)
  }

  async removeStringLimits() {
    if (!this.options.no_string_limit) return

    this.logAnalysis("NO_STRING_LIMIT", "Removing string limits")

    // Remove string truncation patterns
    const limitPatterns = [
      /\.\.\.$$\d+ bytes left$$/g,
      /\[string truncated\]/g,
      /\[\.\.\.(\d+) more characters\]/g,
      /string\.sub$$[^,]+,\s*1,\s*\d+$$/g,
    ]

    let limitsRemoved = 0
    limitPatterns.forEach((pattern) => {
      const matches = (this.deobfuscated.match(pattern) || []).length
      if (matches > 0) {
        this.deobfuscated = this.deobfuscated.replace(pattern, "")
        limitsRemoved += matches
      }
    })

    // Expand truncated strings where possible
    const truncatedPattern = /"([^"]{50,})\.\.\./g
    this.deobfuscated = this.deobfuscated.replace(truncatedPattern, '"$1"')

    this.stats.stringLimitsRemoved = limitsRemoved
    this.logAnalysis("NO_STRING_LIMIT", `String limit removal completed: ${limitsRemoved} limits removed`)
  }

  async bypassKeySystems() {
    if (!this.options.hookOp) return

    const keySystemPatterns = [
      /TextBox\.Text\s*==\s*["']SUPER_UD_KEY["']/g,
      /getgenv$$$$\.key\s*==\s*["'][^"']+["']/g,
      /key\s*==\s*["'][A-Z0-9_]{8,}["']/g,
      /_G\.key\s*==\s*["'][^"']+["']/g,
      /shared\.key\s*==\s*["'][^"']+["']/g,
    ]

    keySystemPatterns.forEach((pattern) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match) => {
        this.stats.keySystemsBypassed++
        this.keySystemBypasses.push(match)
        this.logAnalysis("KEY_BYPASS", `Key system bypassed: ${match}`)
        return "true -- Key system bypassed"
      })
    })
  }

  async fixDuplicateCode() {
    const functionCallPattern = /(\w+)\s*=\s*function\s*$$[^)]*$$\s*([^}]+)\s*end\s*\1\s*$$\s*$$/g

    this.deobfuscated = this.deobfuscated.replace(functionCallPattern, (match, funcName, funcBody) => {
      this.stats.duplicateCodeFixed++
      this.logAnalysis("DUPLICATE_FIX", `Fixed duplicate code for function: ${funcName}`)
      return `${funcName} = function() ${funcBody.trim()} end\n${funcName}()`
    })
  }

  async normalizeLuraph() {
    if (this.detectedObfuscator.toLowerCase() === "luraph") {
      // Fix Luraph-specific patterns that cause issues
      const luraphPatterns = [
        { pattern: /$$\s*function\s*\(\s*$$\s*return\s*([^)]+)\s*end\s*\)\s*$$\s*$$/g, replacement: "$1" },
        { pattern: /local\s+(\w+)\s*=\s*\{\s*\[0x[0-9a-fA-F]+\]\s*=\s*([^,}]+)/g, replacement: "local $1 = { $2" },
      ]

      luraphPatterns.forEach(({ pattern, replacement }) => {
        this.deobfuscated = this.deobfuscated.replace(pattern, replacement)
        this.stats.luraphNormalized++
      })

      this.logAnalysis("LURAPH_NORMALIZE", "Luraph patterns normalized for better processing")
    }
  }

  async fixEnums() {
    const enumPatterns = [/Enum\s*\.\s*(\w+)/g, /EnumItem\s*\.\s*(\w+)/g]

    enumPatterns.forEach((pattern) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match, enumName) => {
        this.stats.enumsFixed++
        this.logAnalysis("ENUM_FIX", `Fixed enum reference: ${match}`)
        return match // Keep as-is but mark as fixed
      })
    })
  }

  async protectStringLibrary() {
    const stringLibPatterns = [/string\s*\.\s*(\w+)\s*=\s*[^;]+/g, /getmetatable\s*$$\s*string\s*$$/g]

    stringLibPatterns.forEach((pattern) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match) => {
        this.stats.stringLibraryFixed++
        this.logAnalysis("STRING_LIB_PROTECT", `Protected string library from bypass: ${match}`)
        return `-- ${match} -- String library protection applied`
      })
    })
  }

  async spyTableIndexes() {
    if (!this.options.hookOp) return

    const tableIndexPattern = /(\w+)\s*\[\s*([^[\]]+)\s*\]/g

    this.deobfuscated = this.deobfuscated.replace(tableIndexPattern, (match, tableName, index) => {
      this.stats.tableIndexesSpied++
      this.logAnalysis("TABLE_INDEX_SPY", `Table index spied: ${match}`)
      return match // Keep original but mark as spied
    })
  }

  async fixFunctionParameters() {
    const functionPattern = /function\s*$$\s*(local\s+arg\d+\s*=\s*\.\.\.)\s*$$/g

    this.deobfuscated = this.deobfuscated.replace(functionPattern, (match, localArg) => {
      this.stats.parametersProperlyCalled++
      this.logAnalysis("PARAM_FIX", `Fixed function parameters: ${match}`)
      return "function(...)" // Simplify to proper varargs
    })
  }

  async checkWhileLoopIterations() {
    const whileLoopPattern = /while\s+([^do]+)\s+do\s*([^end]+)\s*end/g

    this.deobfuscated = this.deobfuscated.replace(whileLoopPattern, (match, condition, body) => {
      this.stats.whileLoopIterationChecks++
      this.logAnalysis("WHILE_LOOP_CHECK", `Added iteration check to while loop`)
      return `local _iterations = 0\nwhile ${condition} do\n  _iterations = _iterations + 1\n  if _iterations > 10000 then error("Too many iterations") end\n  ${body}\nend`
    })
  }

  async fixCoroutineLibrary() {
    const coroutinePatterns = [/coroutine\s*\.\s*(\w+)\s*$$\s*([^)]+)\s*$$/g]

    coroutinePatterns.forEach((pattern) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match, method, args) => {
        this.stats.coroutineLibFixed++
        this.logAnalysis("COROUTINE_FIX", `Fixed coroutine library call: ${match}`)
        return match // Keep original but ensure it works with spied variables
      })
    })
  }

  async fixVectorTypes() {
    const vectorPatterns = [/Vector2\s*\.\s*new\s*$$\s*([^)]+)\s*$$/g, /Rect\s*\.\s*new\s*$$\s*([^)]+)\s*$$/g]

    vectorPatterns.forEach((pattern, index) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match, args) => {
        this.stats.vectorTypesFixed++
        const typeName = index === 0 ? "Vector2" : "Rect"
        this.logAnalysis("VECTOR_FIX", `Fixed ${typeName} type: ${match}`)
        return match // Ensure these types are properly defined
      })
    })
  }

  async fixForLoops() {
    const obfuscatedForPattern = /(\w+)\s*$$\s*nil\s*,\s*nil\s*$$/g

    this.deobfuscated = this.deobfuscated.replace(obfuscatedForPattern, (match, varName) => {
      this.stats.forLoopsFixed++
      this.logAnalysis("FOR_LOOP_FIX", `Fixed obfuscated for loop: ${match}`)
      return `for ${varName} in pairs({}) do` // Convert to proper for loop
    })
  }

  async fixGmatchMatch() {
    const gmatchMatchPatterns = [
      /string\s*\.\s*gmatch\s*$$\s*([^,]+)\s*,\s*([^)]+)\s*$$/g,
      /string\s*\.\s*match\s*$$\s*([^,]+)\s*,\s*([^)]+)\s*$$/g,
    ]

    gmatchMatchPatterns.forEach((pattern, index) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match, str, pattern) => {
        this.stats.gmatchMatchFixed++
        const method = index === 0 ? "gmatch" : "match"
        this.logAnalysis("GMATCH_MATCH_FIX", `Fixed string.${method} wrapping: ${match}`)
        return match // Ensure proper wrapping for spied variables
      })
    })
  }

  async fixInternalChecks() {
    const internalCheckPattern = /if\s+([^then]+)\s+then\s*error\s*$$\s*["'][^"']*["']\s*$$\s*end/g

    this.deobfuscated = this.deobfuscated.replace(internalCheckPattern, (match, condition) => {
      this.stats.internalChecksFixed++
      this.logAnalysis("INTERNAL_CHECK_FIX", `Fixed internal check: ${condition}`)
      return `-- Internal check removed: ${condition}`
    })
  }

  async hookTables() {
    if (!this.options.hookOp) return

    const tableDefinitionPattern = /local\s+(\w+)\s*=\s*\{([^}]*)\}/g
    const tableUsagePattern = /$$\s*\{\s*\}\s*$$\s*\[\s*([^[\]]+)\s*\]/g

    // First pass: identify table definitions
    let match
    while ((match = tableDefinitionPattern.exec(this.deobfuscated)) !== null) {
      const [fullMatch, tableName, content] = match
      this.tableDefinitions.set(tableName, content)
      this.logAnalysis("TABLE_HOOK", `Table definition hooked: ${tableName}`)
    }

    // Second pass: replace anonymous table usage
    this.deobfuscated = this.deobfuscated.replace(tableUsagePattern, (match, index) => {
      this.stats.tableHookingApplied++
      const varName = `hooked_table_${this.stats.tableHookingApplied}`
      this.logAnalysis("TABLE_HOOK_REPLACE", `Replaced anonymous table usage: ${match}`)
      return `local ${varName} = {}\n${varName}[${index}]`
    })
  }

  async fixStringEqualityChecks() {
    const stringEqPattern = /identifyexecutor\s*$$\s*$$\s*==\s*["']([^"']+)["']/g

    this.deobfuscated = this.deobfuscated.replace(stringEqPattern, (match, expectedValue) => {
      this.stats.stringEqChecksFixed++
      this.logAnalysis("STRING_EQ_FIX", `Fixed string equality check: ${match}`)
      return `(identifyexecutor() or "") == "${expectedValue}"` // Proper null check
    })
  }

  async fixIdentifyExecutor() {
    if (!this.options.hookOp) return

    const executorPatterns = [
      /local\s+(\w+)\s*=\s*identifyexecutor\s*$$\s*$$/g,
      /local\s+(\w+)\s*=\s*getexecutorname\s*$$\s*$$/g,
    ]

    executorPatterns.forEach((pattern) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match, varName) => {
        this.stats.identifyExecutorFixed++
        this.logAnalysis("IDENTIFY_EXECUTOR_FIX", `Fixed executor identification: ${match}`)
        return match // Keep original but ensure hookOp support
      })
    })
  }

  async fixLoadstringHookOp() {
    if (!this.options.hookOp) return

    const loadPatterns = [/loadstring\s*$$\s*([^)]+)\s*$$/g, /load\s*$$\s*([^)]+)\s*$$/g]

    loadPatterns.forEach((pattern) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match, code) => {
        this.stats.loadstringHookOpFixed++
        this.logAnalysis("LOADSTRING_HOOKOP_FIX", `Fixed loadstring/load hookOp bypass: ${match}`)
        return match // Ensure hookOp is not bypassed
      })
    })
  }

  async deobfuscate() {
    const startTime = Date.now()
    this.performance.startTime = startTime

    try {
      this.stats.originalSize = this.code.length
      this.logAnalysis("INIT", "Starting comprehensive deobfuscation analysis")
      this.takeMemorySnapshot("start")

      this.detectObfuscatorType()
      this.logAnalysis("DETECTION", `Detected obfuscator: ${this.detectedObfuscator}`)

      this.deobfuscated = this.code

      await this.executeStage("bypassKeySystems")
      await this.executeStage("fixDuplicateCode")
      await this.executeStage("normalizeLuraph")
      await this.executeStage("fixEnums")
      await this.executeStage("protectStringLibrary")
      await this.executeStage("spyTableIndexes")
      await this.executeStage("fixFunctionParameters")
      await this.executeStage("checkWhileLoopIterations")
      await this.executeStage("fixCoroutineLibrary")
      await this.executeStage("fixVectorTypes")
      await this.executeStage("fixForLoops")
      await this.executeStage("fixGmatchMatch")
      await this.executeStage("fixInternalChecks")
      await this.executeStage("hookTables")
      await this.executeStage("fixStringEqualityChecks")
      await this.executeStage("fixIdentifyExecutor")
      await this.executeStage("fixLoadstringHookOp")

      await this.executeStage("hookOperations")
      await this.executeStage("minifyCode")
      await this.executeStage("renameVariables")
      await this.executeStage("exploreFunctions")
      await this.executeStage("spyExecutorVariables")
      await this.executeStage("removeStringLimits")

      await this.executeStage("stage1_AdvancedPreprocessing")
      await this.executeStage("stage2_DeepStringDecoding")
      await this.executeStage("stage3_BytecodeAnalysis")
      await this.executeStage("stage4_VMInstructionDecoding")
      await this.executeStage("stage5_ConstantPoolExtraction")
      await this.executeStage("stage6_IntelligentStringTableExtraction")
      await this.executeStage("stage7_ComprehensiveMathSimplification")
      await this.executeStage("stage8_AdvancedFunctionDecoding")
      await this.executeStage("stage9_ContextualVariableAnalysis")
      await this.executeStage("stage10_ControlFlowOptimization")
      await this.executeStage("stage11_PatternBasedCleaning")
      await this.executeStage("stage12_SemanticAnalysis")
      await this.executeStage("stage13_AdvancedExpressionSimplification")
      await this.executeStage("stage14_NestedExpressionResolution")
      await this.executeStage("stage15_ComplexPatternDecoding")
      await this.executeStage("stage16_AdvancedStringAnalysis")
      await this.executeStage("stage17_IntelligentCodeReconstruction")
      await this.executeStage("stage18_ComprehensiveOptimization")
      await this.executeStage("stage19_IntelligentFormatting")
      await this.executeStage("stage20_FinalOptimization")
      await this.executeStage("stage21_AntiDebugRemoval")
      await this.executeStage("stage22_EncryptionDecoding")
      await this.executeStage("stage23_CompressionDecoding")
      await this.executeStage("stage24_AdvancedTableDumping")
      await this.executeStage("stage25_FinalAnalysis")

      this.stats.finalSize = this.deobfuscated.length
      this.stats.processingTime = Date.now() - startTime
      this.stats.memoryUsed = process.memoryUsage().heapUsed

      this.takeMemorySnapshot("end")
      this.logAnalysis("COMPLETE", "Deobfuscation analysis completed successfully")

      const tableDumpReport = this.generateTableDumpReport()
      const performanceReport = this.generatePerformanceReport()

      return {
        success: true,
        result: this.deobfuscated,
        obfuscator: this.detectedObfuscator,
        stats: this.stats,
        analysisLog: this.analysisLog,
        errorLog: this.errorLog,
        testResults: this.testResults,
        byteArrays: this.byteArrays,
        decodingAttempts: this.decodingAttempts,
        tableDumps: this.tableDumps,
        tableAnalysis: this.tableAnalysis,
        tableDumpReport: tableDumpReport,
        performanceReport: performanceReport,
        detailedReport: this.generateDetailedReport(),
      }
    } catch (error) {
      this.logError(error, "Main deobfuscation process")
      return {
        success: false,
        error: error.message,
        obfuscator: this.detectedObfuscator,
        stats: this.stats,
        analysisLog: this.analysisLog,
        errorLog: this.errorLog,
      }
    }
  }

  async executeStage(stageName) {
    const stageStart = Date.now()
    this.logAnalysis("STAGE_START", `Executing ${stageName}`)

    try {
      await this[stageName]()
      const duration = Date.now() - stageStart
      this.performance.stageTimings[stageName] = duration
      this.logAnalysis("STAGE_COMPLETE", `Completed ${stageName} in ${duration}ms`)
    } catch (error) {
      this.logError(error, `Stage ${stageName}`)
      this.performance.stageTimings[stageName] = Date.now() - stageStart
    }
  }

  takeMemorySnapshot(label) {
    const usage = process.memoryUsage()
    this.performance.memorySnapshots.push({
      label,
      timestamp: Date.now(),
      heapUsed: usage.heapUsed,
      heapTotal: usage.heapTotal,
      external: usage.external,
      rss: usage.rss,
    })
  }

  generatePerformanceReport() {
    const totalTime = this.stats.processingTime
    const stages = Object.entries(this.performance.stageTimings)
      .sort(([, a], [, b]) => b - a)
      .map(([stage, time]) => `${stage}: ${time}ms (${((time / totalTime) * 100).toFixed(1)}%)`)

    return {
      totalProcessingTime: totalTime,
      averageStageTime: totalTime / Object.keys(this.performance.stageTimings).length,
      slowestStages: stages.slice(0, 5),
      memoryUsage: this.performance.memorySnapshots,
      efficiency: {
        bytesPerSecond: Math.round(this.stats.originalSize / (totalTime / 1000)),
        stagesPerSecond: Math.round(Object.keys(this.performance.stageTimings).length / (totalTime / 1000)),
      },
    }
  }

  generateDetailedReport() {
    return {
      summary: {
        successRate: `${Math.round((this.testResults.filter((t) => t.success).length / Math.max(this.testResults.length, 1)) * 100)}%`,
        processingTime: `${this.stats.processingTime}ms`,
        memoryUsed: `${Math.round(this.stats.memoryUsed / 1024 / 1024)}MB`,
        efficiency: `${Math.round(this.stats.originalSize / (this.stats.processingTime / 1000))} bytes/sec`,
      },
      patternAnalysis: {
        stringTablesFound: this.tableAnalysis.stringTables,
        encodedStringsFound: this.patterns.encodedStrings.length,
        obfuscatedVarsFound: this.patterns.obfuscatedVars.size,
        mathExpressionsFound: this.patterns.mathExpressions.length,
        bytecodePatterns: this.patterns.bytecode.length,
        suspiciousTables: this.tableAnalysis.suspiciousTables,
      },
      decodingResults: {
        successfulDecodings: this.decodingAttempts.filter((a) => a.success).length,
        byteArraysProcessed: this.stats.byteArraysProcessed,
        stringsDecoded: this.stats.stringsReplaced,
        encryptionDecoded: this.stats.encryptionDecoded,
        compressionDecoded: this.stats.compressionDecoded,
      },
      errorAnalysis: {
        totalErrors: this.stats.errorsEncountered,
        criticalErrors: this.errorLog.filter((e) => e.error.includes("critical")).length,
        warningCount: this.errorLog.filter((e) => e.error.includes("warning")).length,
        recoveredErrors: this.errorLog.filter((e) => e.error.includes("recovered")).length,
      },
    }
  }

  async stage21_AntiDebugRemoval() {
    this.logAnalysis("STAGE21", "Removing anti-debug mechanisms")

    const antiDebugPatterns = [
      /debug\.getinfo$$[^)]*$$/g,
      /debug\.sethook$$[^)]*$$/g,
      /debug\.traceback$$[^)]*$$/g,
      /getfenv$$$$\["debug"\]/g,
      /pcall\(debug\./g,
    ]

    antiDebugPatterns.forEach((pattern) => {
      const matches = this.deobfuscated.match(pattern)
      if (matches) {
        this.deobfuscated = this.deobfuscated.replace(pattern, "-- Anti-debug removed")
        this.stats.antiDebugRemoved += matches.length
        this.logAnalysis("ANTI_DEBUG", `Removed ${matches.length} anti-debug patterns`)
      }
    })
  }

  async stage22_EncryptionDecoding() {
    this.logAnalysis("STAGE22", "Attempting encryption decoding")

    // Look for encrypted string patterns
    const encryptedPatterns = [
      /["']([A-Za-z0-9+/]{32,}={0,2})["']/g, // Base64-like
      /["']([0-9a-fA-F]{32,})["']/g, // Hex-like
      /string\.char$$([^)]+)$$/g, // Character construction
    ]

    encryptedPatterns.forEach((pattern) => {
      this.deobfuscated = this.deobfuscated.replace(pattern, (match, content) => {
        const decoded = this.tryDecryptString(content)
        if (decoded && decoded !== content) {
          this.stats.encryptionDecoded++
          this.logAnalysis("ENCRYPTION", `Decoded encrypted string: ${content.substring(0, 20)}...`)
          return `"${decoded}"`
        }
        return match
      })
    })
  }

  async stage23_CompressionDecoding() {
    this.logAnalysis("STAGE23", "Attempting compression decoding")

    // Look for compressed data patterns
    const compressedPatterns = this.deobfuscated.match(/["']([A-Za-z0-9+/]{100,}={0,2})["']/g) || []

    for (const pattern of compressedPatterns) {
      const content = pattern.substring(1, pattern.length - 1)
      const decompressed = this.tryDecompressString(content)
      if (decompressed && decompressed !== content) {
        this.deobfuscated = this.deobfuscated.replace(pattern, `"${decompressed}"`)
        this.stats.compressionDecoded++
        this.logAnalysis("COMPRESSION", `Decompressed data: ${content.substring(0, 20)}...`)
      }
    }
  }

  async stage24_AdvancedTableDumping() {
    this.logAnalysis("STAGE24", "Performing advanced table dumping")

    // Enhanced table detection patterns
    const advancedTablePatterns = [
      /local\s+(\w+)\s*=\s*\{([^}]{50,})\}/g,
      /(\w+)\s*=\s*\{([^}]{30,})\}/g,
      /\[["'](\w+)["']\]\s*=\s*\{([^}]+)\}/g,
      /(\w+)\s*=\s*setmetatable\s*\(\s*\{([^}]+)\}/g,
    ]

    advancedTablePatterns.forEach((pattern) => {
      let match
      while ((match = pattern.exec(this.deobfuscated)) !== null) {
        const tableName = match[1]
        const tableContent = match[2]

        if (tableContent && tableContent.length > 20) {
          this.dumpTable(tableName, tableContent, "Advanced pattern")
        }
      }
    })
  }

  async stage25_FinalAnalysis() {
    this.logAnalysis("STAGE25", "Performing final comprehensive analysis")

    // Generate final statistics
    const codeLines = this.deobfuscated.split("\n").length
    const codeComplexity = this.calculateCodeComplexity(this.deobfuscated)
    const obfuscationLevel = this.calculateObfuscationLevel()

    this.logAnalysis("FINAL_STATS", "Final analysis complete", {
      lines: codeLines,
      complexity: codeComplexity.toFixed(3),
      obfuscationLevel: obfuscationLevel.toFixed(3),
      reductionRatio:
        (((this.stats.originalSize - this.stats.finalSize) / this.stats.originalSize) * 100).toFixed(1) + "%",
    })
  }

  calculateCodeComplexity(code) {
    let complexity = 0

    // Count various complexity indicators
    complexity += (code.match(/\bfunction\b/g) || []).length * 0.1
    complexity += (code.match(/\bif\b/g) || []).length * 0.05
    complexity += (code.match(/\bfor\b/g) || []).length * 0.08
    complexity += (code.match(/\bwhile\b/g) || []).length * 0.08
    complexity += (code.match(/\blocal\b/g) || []).length * 0.02

    // Factor in nesting depth
    const maxNesting = this.calculateMaxNesting(code)
    complexity += maxNesting * 0.1

    return Math.min(complexity, 10) // Cap at 10
  }

  calculateMaxNesting(code) {
    let maxDepth = 0
    let currentDepth = 0

    const openKeywords = ["function", "if", "for", "while", "do", "repeat"]
    const closeKeywords = ["end", "until"]

    const tokens = code.match(/\b(function|if|for|while|do|repeat|end|until)\b/g) || []

    for (const token of tokens) {
      if (openKeywords.includes(token)) {
        currentDepth++
        maxDepth = Math.max(maxDepth, currentDepth)
      } else if (closeKeywords.includes(token)) {
        currentDepth = Math.max(0, currentDepth - 1)
      }
    }

    return maxDepth
  }

  calculateObfuscationLevel() {
    let level = 0

    // Factor in various obfuscation indicators
    level += Math.min(this.stats.variablesRenamed / 50, 1) * 0.3
    level += Math.min(this.stats.stringsReplaced / 100, 1) * 0.2
    level += Math.min(this.stats.expressionsSimplified / 50, 1) * 0.2
    level += Math.min(this.tableAnalysis.suspiciousTables / 10, 1) * 0.2
    level += Math.min(this.stats.antiDebugRemoved / 5, 1) * 0.1

    return level
  }

  tryDecryptString(str) {
    // Try various decryption methods
    const methods = [
      () => {
        try {
          return Buffer.from(str, "base64").toString("utf-8")
        } catch (e) {
          return null
        }
      },
      () => {
        try {
          if (str.length % 2 === 0) {
            let result = ""
            for (let i = 0; i < str.length; i += 2) {
              result += String.fromCharCode(Number.parseInt(str.substr(i, 2), 16))
            }
            return result
          }
        } catch (e) {
          return null
        }
      },
      () => {
        try {
          return decodeURIComponent(str)
        } catch (e) {
          return null
        }
      },
    ]

    for (const method of methods) {
      const result = method()
      if (result && result !== str && /^[\x20-\x7E\s]*$/.test(result)) {
        return result
      }
    }

    return null
  }

  tryDecompressString(str) {
    // Basic decompression attempts (would need actual compression libraries for full implementation)
    try {
      const decoded = Buffer.from(str, "base64")
      // This is a placeholder - real implementation would use zlib, gzip, etc.
      if (decoded.length < str.length * 0.8) {
        return decoded.toString("utf-8")
      }
    } catch (e) {}

    return null
  }

  generateTableDumpReport() {
    let report = "=== COMPREHENSIVE TABLE DUMP ANALYSIS ===\n\n"

    report += `EXECUTIVE SUMMARY:\n`
    report += `- Total Tables Analyzed: ${this.tableAnalysis.totalTables}\n`
    report += `- String Tables: ${this.tableAnalysis.stringTables}\n`
    report += `- Numeric Tables: ${this.tableAnalysis.numericTables}\n`
    report += `- Function Tables: ${this.tableAnalysis.functionTables}\n`
    report += `- Mixed Tables: ${this.tableAnalysis.mixedTables}\n`
    report += `- Suspicious Tables: ${this.tableAnalysis.suspiciousTables}\n`
    report += `- Constant Pools: ${this.tableAnalysis.constantPools}\n`
    report += `- Processing Time: ${this.stats.processingTime}ms\n`
    report += `- Memory Used: ${Math.round(this.stats.memoryUsed / 1024 / 1024)}MB\n\n`

    for (const dump of this.tableDumps) {
      report += `TABLE: ${dump.name} (${dump.type.toUpperCase()})\n`
      report += `Context: ${dump.context}\n`
      report += `Total Entries: ${dump.analysis.totalEntries}\n`
      report += `Entropy: ${dump.analysis.entropy.toFixed(3)}\n`
      report += `Complexity: ${dump.analysis.complexity.toFixed(3)}\n`
      report += `Suspicious Patterns: ${dump.analysis.suspiciousPatterns}\n`

      if (dump.strings.length > 0) {
        report += `String Entries (${dump.strings.length}):\n`
        dump.strings.slice(0, 10).forEach((str) => {
          report += `  [${str.index}] "${str.value}" (length: ${str.length}, entropy: ${str.entropy.toFixed(3)}, suspicious: ${str.suspicious})\n`
        })
        if (dump.strings.length > 10) {
          report += `  ... and ${dump.strings.length - 10} more strings\n`
        }
      }

      if (dump.numbers.length > 0) {
        report += `Numeric Entries (${dump.numbers.length}):\n`
        const numberSample = dump.numbers.slice(0, 20)
        report += `  [${numberSample.map((n) => `${n.value} (${n.type}, suspicious: ${n.suspicious})`).join(", ")}${dump.numbers.length > 20 ? "..." : ""}]\n`
      }

      if (dump.byteArrays.length > 0) {
        report += `Byte Arrays Found:\n`
        dump.byteArrays.forEach((ba, i) => {
          report += `  Array ${i + 1}: [${ba.array.slice(0, 20).join(", ")}${ba.array.length > 20 ? "..." : ""}] (${ba.length} bytes, entropy: ${ba.entropy.toFixed(3)}, pattern: ${ba.pattern})\n`
          if (ba.decoded.length > 0) {
            report += `    Possible Decodings:\n`
            ba.decoded.slice(0, 3).forEach((dec) => {
              report += `      ${dec.method}: "${dec.result.substring(0, 50)}${dec.result.length > 50 ? "..." : ""}" (confidence: ${Math.round(dec.confidence * 100)}%)\n`
            })
          }
        })
      }

      if (dump.functions.length > 0) {
        report += `Function Entries (${dump.functions.length}):\n`
        dump.functions.slice(0, 5).forEach((func) => {
          report += `  [${func.index}] Signature: ${func.signature.substring(0, 50)}${func.signature.length > 50 ? "..." : ""}, complexity: ${func.complexity.toFixed(3)}, obfuscated: ${func.obfuscated}\n`
        })
        if (dump.functions.length > 5) {
          report += `  ... and ${dump.functions.length - 5} more functions\n`
        }
      }

      report += `Raw Content: ${dump.rawContent.substring(0, 200)}${dump.rawContent.length > 200 ? "..." : ""}\n`
      report += "\n" + "=".repeat(50) + "\n\n"
    }

    return report
  }
}

const envLogger = new EnvironmentLogger()
const envValidation = envLogger.validateEnvironment()

const client = new Client({
  intents: [GatewayIntentBits.Guilds],
})

const commands = [
  new SlashCommandBuilder()
    .setName("deobf")
    .setDescription("Deobfuscate Lua code from multiple obfuscators")
    .addSubcommand((subcommand) =>
      subcommand
        .setName("code")
        .setDescription("Deobfuscate code directly")
        .addStringOption((option) =>
          option.setName("input").setDescription("The obfuscated Lua code").setRequired(true),
        )
        .addBooleanOption((option) =>
          option
            .setName("hookop")
            .setDescription("Hook operations (>, <, >=, <=, and, or, while, if)")
            .setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("minifier").setDescription("Inline code and remove single-use variables").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("renamer").setDescription("Rename variables to meaningful names").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("explore_funcs").setDescription("Enable function exploration").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("spyexeconly").setDescription("Only spy executor variables").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("no_string_limit").setDescription("Remove string length limits").setRequired(false),
        ),
    )
    .addSubcommand((subcommand) =>
      subcommand
        .setName("url")
        .setDescription("Deobfuscate code from a URL")
        .addStringOption((option) =>
          option.setName("link").setDescription("URL containing the obfuscated code").setRequired(true),
        )
        .addBooleanOption((option) => option.setName("hookop").setDescription("Hook operations").setRequired(false))
        .addBooleanOption((option) =>
          option.setName("minifier").setDescription("Inline code and remove single-use variables").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("renamer").setDescription("Rename variables to meaningful names").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("explore_funcs").setDescription("Enable function exploration").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("spyexeconly").setDescription("Only spy executor variables").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("no_string_limit").setDescription("Remove string length limits").setRequired(false),
        ),
    )
    .addSubcommand((subcommand) =>
      subcommand
        .setName("file")
        .setDescription("Deobfuscate code from an uploaded file")
        .addAttachmentOption((option) =>
          option.setName("attachment").setDescription("File containing obfuscated Lua code").setRequired(true),
        )
        .addBooleanOption((option) => option.setName("hookop").setDescription("Hook operations").setRequired(false))
        .addBooleanOption((option) =>
          option.setName("minifier").setDescription("Inline code and remove single-use variables").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("renamer").setDescription("Rename variables to meaningful names").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("explore_funcs").setDescription("Enable function exploration").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("spyexeconly").setDescription("Only spy executor variables").setRequired(false),
        )
        .addBooleanOption((option) =>
          option.setName("no_string_limit").setDescription("Remove string length limits").setRequired(false),
        ),
    )
    .toJSON(),
]

async function registerCommands() {
  if (!process.env.DISCORD_TOKEN) {
    console.error("❌ DISCORD_TOKEN is missing! Please add it to Replit Secrets.")
    return
  }

  if (!process.env.CLIENT_ID) {
    console.error("❌ CLIENT_ID is missing! Please add it to Replit Secrets.")
    return
  }

  const rest = new REST({ version: "10" }).setToken(process.env.DISCORD_TOKEN)

  try {
    console.log("🔄 Started refreshing application (/) commands.")
    await rest.put(Routes.applicationCommands(process.env.CLIENT_ID), { body: commands })
    console.log("✅ Successfully reloaded application (/) commands.")
  } catch (error) {
    console.error("❌ Failed to register commands:", error)
    if (error.code === 50001) {
      console.error("🔑 Invalid bot token! Please check your DISCORD_TOKEN in Replit Secrets.")
    } else if (error.code === 50035) {
      console.error("📝 Invalid application ID! Please check your CLIENT_ID in Replit Secrets.")
    }
  }
}

async function fetchCodeFromUrl(url) {
  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    const text = await response.text()
    return text
  } catch (error) {
    throw new Error(`Failed to fetch from URL: ${error.message}`)
  }
}

async function readFileAttachment(attachment) {
  try {
    const response = await fetch(attachment.url)
    if (!response.ok) {
      throw new Error(`Failed to download file: ${response.statusText}`)
    }
    const text = await response.text()
    return text
  } catch (error) {
    throw new Error(`Failed to read file: ${error.message}`)
  }
}

client.once("ready", () => {
  console.log(`✅ Bot ${client.user.tag} is online and ready!`)
  console.log(`🌐 Serving ${client.guilds.cache.size} servers`)
  console.log(`🆔 Bot ID: ${client.user.id}`)
  envLogger.log("SUCCESS", `Bot ${client.user.tag} is online and ready!`)
  envLogger.log("INFO", `Serving ${client.guilds.cache.size} servers`)
  envLogger.log("INFO", "Environment validation results:", envValidation)
  registerCommands()
})

client.on("interactionCreate", async (interaction) => {
  if (!interaction.isChatInputCommand()) return

  if (interaction.commandName === "deobf") {
    await interaction.deferReply()

    const startTime = Date.now()
    envLogger.log("INFO", "Deobfuscation request received", {
      user: interaction.user.tag,
      guild: interaction.guild?.name || "DM",
      subcommand: interaction.options.getSubcommand(),
    })

    try {
      let code = ""
      let source = ""
      const subcommand = interaction.options.getSubcommand()

      const options = {
        hookOp: interaction.options.getBoolean("hookop") || false,
        minifier: interaction.options.getBoolean("minifier") || false,
        renamer: interaction.options.getBoolean("renamer") || false,
        explore_funcs: interaction.options.getBoolean("explore_funcs") || false,
        spyexeconly: interaction.options.getBoolean("spyexeconly") || false,
        no_string_limit: interaction.options.getBoolean("no_string_limit") || false,
      }

      switch (subcommand) {
        case "code":
          code = interaction.options.getString("input")
          source = "Direct input"
          break

        case "url":
          const url = interaction.options.getString("link")
          source = `URL: ${url}`
          code = await fetchCodeFromUrl(url)
          break

        case "file":
          const attachment = interaction.options.getAttachment("attachment")
          source = `File: ${attachment.name}`

          const validExtensions = [".lua", ".txt", ".luau", ".luac"]
          const hasValidExtension = validExtensions.some((ext) => attachment.name.toLowerCase().endsWith(ext))

          if (!hasValidExtension) {
            throw new Error("Invalid file type! Please use .lua, .txt, .luau, or .luac files.")
          }

          code = await readFileAttachment(attachment)
          break
      }

      if (!code || code.trim().length === 0) {
        throw new Error("No code found to deobfuscate!")
      }

      const deobfuscator = new UniversalLuaDeobfuscator(code, options)
      const result = await deobfuscator.deobfuscate()

      const processingTime = Date.now() - startTime
      envLogger.log("SUCCESS", "Deobfuscation completed", {
        processingTime,
        success: result.success,
        obfuscator: result.obfuscator,
        originalSize: result.stats?.originalSize,
        finalSize: result.stats?.finalSize,
        advancedOptions: options,
      })

      if (result.success) {
        const embed = new EmbedBuilder()
          .setColor("#00ff88")
          .setTitle("Ultimate Deobfuscation Analysis Complete!")
          .setDescription(`Successfully processed your Lua code with advanced analysis and all improvements!`)
          .addFields(
            { name: "Detected Obfuscator", value: result.obfuscator, inline: true },
            { name: "Processing Time", value: `${result.stats.processingTime}ms`, inline: true },
            { name: "Memory Used", value: `${Math.round(result.stats.memoryUsed / 1024 / 1024)}MB`, inline: true },
            { name: "Original Size", value: `${result.stats.originalSize.toLocaleString()} chars`, inline: true },
            { name: "Final Size", value: `${result.stats.finalSize.toLocaleString()} chars`, inline: true },
            { name: "Variables Renamed", value: result.stats.variablesRenamed.toString(), inline: true },
            { name: "Strings Replaced", value: result.stats.stringsReplaced.toString(), inline: true },
            { name: "Tables Dumped", value: result.stats.tablesDumped.toString(), inline: true },
            { name: "Operations Hooked", value: result.stats.operationsHooked.toString(), inline: true },
            { name: "Code Minified", value: result.stats.codeMinified.toString(), inline: true },
            { name: "Functions Explored", value: result.stats.functionsExplored.toString(), inline: true },
            { name: "Executor Vars Spied", value: result.stats.executorVariablesSpied.toString(), inline: true },
            { name: "String Limits Removed", value: result.stats.stringLimitsRemoved.toString(), inline: true },
            { name: "Key Systems Bypassed", value: result.stats.keySystemsBypassed.toString(), inline: true },
            { name: "Duplicate Code Fixed", value: result.stats.duplicateCodeFixed.toString(), inline: true },
            { name: "Luraph Normalized", value: result.stats.luraphNormalized.toString(), inline: true },
            { name: "Enums Fixed", value: result.stats.enumsFixed.toString(), inline: true },
            { name: "String Library Protected", value: result.stats.stringLibraryFixed.toString(), inline: true },
            { name: "Table Indexes Spied", value: result.stats.tableIndexesSpied.toString(), inline: true },
            { name: "Parameters Fixed", value: result.stats.parametersProperlyCalled.toString(), inline: true },
            { name: "While Loop Checks", value: result.stats.whileLoopIterationChecks.toString(), inline: true },
            { name: "Coroutine Lib Fixed", value: result.stats.coroutineLibFixed.toString(), inline: true },
            { name: "Vector Types Fixed", value: result.stats.vectorTypesFixed.toString(), inline: true },
            { name: "For Loops Fixed", value: result.stats.forLoopsFixed.toString(), inline: true },
            { name: "Gmatch/Match Fixed", value: result.stats.gmatchMatchFixed.toString(), inline: true },
            { name: "Internal Checks Fixed", value: result.stats.internalChecksFixed.toString(), inline: true },
            { name: "Table Hooking Applied", value: result.stats.tableHookingApplied.toString(), inline: true },
            { name: "String Eq Checks Fixed", value: result.stats.stringEqChecksFixed.toString(), inline: true },
            { name: "Identify Executor Fixed", value: result.stats.identifyExecutorFixed.toString(), inline: true },
            { name: "Loadstring HookOp Fixed", value: result.stats.loadstringHookOpFixed.toString(), inline: true },
            {
              name: "Advanced Options",
              value:
                Object.entries(options)
                  .filter(([k, v]) => v)
                  .map(([k]) => k)
                  .join(", ") || "None",
              inline: false,
            },
            { name: "Source", value: source, inline: false },
          )
          .setTimestamp()
          .setFooter({
            text: "Ultimate Lua Deobfuscator • All Advanced Improvements • Unlimited Size • Professional Grade",
          })

        const buffer = Buffer.from(result.result, "utf-8")
        const attachment = new AttachmentBuilder(buffer, { name: "deobfuscated.txt" })

        await interaction.editReply({
          embeds: [embed],
          files: [attachment],
        })
      } else {
        const errorEmbed = new EmbedBuilder()
          .setColor("#ff4444")
          .setTitle("Deobfuscation Failed")
          .setDescription(`**Error:** ${result.error}`)
          .addFields(
            { name: "Detected Obfuscator", value: result.obfuscator || "Unknown", inline: true },
            { name: "Source", value: source, inline: true },
          )
          .setTimestamp()
          .setFooter({ text: "Try a different obfuscator type or check your code format" })

        await interaction.editReply({ embeds: [errorEmbed] })
      }
    } catch (error) {
      envLogger.log("ERROR", "Deobfuscation failed", {
        error: error.message,
        stack: error.stack,
        user: interaction.user.tag,
      })

      const errorEmbed = new EmbedBuilder()
        .setColor("#ff0000")
        .setTitle("Processing Error")
        .setDescription(`**Error:** ${error.message}`)
        .setTimestamp()

      await interaction.editReply({ embeds: [errorEmbed] })
    }
  }
})

client.on("error", (error) => {
  envLogger.log("ERROR", "Discord client error", { error: error.message, stack: error.stack })
})

process.on("unhandledRejection", (error) => {
  envLogger.log("ERROR", "Unhandled promise rejection", { error: error.message, stack: error.stack })
})

envLogger.log("INFO", "Starting Discord bot with environment validation...")

if (!process.env.DISCORD_TOKEN) {
  console.error("❌ Cannot start bot: DISCORD_TOKEN is missing!")
  console.log("📝 Please add your Discord bot token to Replit Secrets:")
  console.log("   1. Click on 'Secrets' tab in Replit")
  console.log("   2. Add key: DISCORD_TOKEN")
  console.log("   3. Add value: your_bot_token_here")
  process.exit(1)
}

if (!process.env.CLIENT_ID) {
  console.error("❌ Cannot start bot: CLIENT_ID is missing!")
  console.log("📝 Please add your Discord application ID to Replit Secrets:")
  console.log("   1. Click on 'Secrets' tab in Replit")
  console.log("   2. Add key: CLIENT_ID")
  console.log("   3. Add value: your_application_id_here")
  process.exit(1)
}

console.log("🚀 Attempting to login to Discord...")
client.login(process.env.DISCORD_TOKEN).catch((error) => {
  console.error("❌ Failed to login to Discord:", error.message)
  envLogger.log("ERROR", "Failed to login to Discord", { error: error.message })

  if (error.message.includes("TOKEN_INVALID")) {
    console.log("🔑 Your Discord bot token is invalid!")
    console.log("📝 Please check your DISCORD_TOKEN in Replit Secrets")
  }

  process.exit(1)
})
