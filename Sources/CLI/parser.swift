#if os(OSX)
  import Darwin
#else
  import Glibc
#endif

struct Option {
  let shortName: String
  let longName: String
  let require: String
  let desc: String

  func usage() -> String {
    return "\(self.shortName) \(self.longName) \(self.require) - \(self.desc)"
  }
}

struct Flag {
  let shortName: String
  let longName: String
  let desc: String

  func usage() -> String {
    return "\(self.shortName) \(self.longName)  - \(self.desc)"
  }
}

public struct Parser {
  private var usage = "No message provided."
  private var options: [Option] = []
  private var flags: [Flag] = []
  private var standAloneFlags: [Flag] = []
  private var helpFlag: Flag?

  public init() {}

  mutating public func usage(_ usage: String) {
    self.usage = usage
  }

  mutating public func option(_ shortName: String, _ longName: String, _ require: String, _ desc: String) {
    let opt = Option(shortName: shortName, longName: longName, require: require, desc: desc)
    self.options.append(opt)
  }

  mutating public func flag(_ shortName: String, _ longName: String, _ desc: String, standAlone: Bool = false) {
    let flag = Flag(shortName: shortName, longName: longName, desc: desc)
    if standAlone {
      self.standAloneFlags.append(flag)
    } else {
      self.flags.append(flag)
    }
  }

  mutating public func helpFlag(_ shortName: String, _ longName: String, _ desc: String) {
    self.helpFlag = Flag(shortName: shortName, longName: longName, desc: desc)
  }

  func printUsageAndExit(_ status: Int32) {
    print(self.usage, "\n")

    for flag in self.flags { print(flag.usage()) }
    for flag in self.standAloneFlags { print(flag.usage()) }
    for opt in self.options { print(opt.usage()) }
    if let helpFlag = self.helpFlag { print("\n", helpFlag.usage()) }

    exit(status)
  }

  public func parse(_ cmdLineArgs: inout [String]) -> [String: Any] {
    // if no command line args are passed then print usage
    if cmdLineArgs.count < 2 { self.printUsageAndExit(1) }

    // check for help flag in cmd line args
    // if flag is found then print usage
    if let helpFlag = self.helpFlag {
      if cmdLineArgs.contains(helpFlag.shortName)
        || cmdLineArgs.contains(helpFlag.longName) {
        self.printUsageAndExit(1)
      }
    }

    // create results hash to be return
    var parserResult: [String: Any] = [:]

    //iterate over the stand-alone flags and extract from cmd line args
    for flag in self.standAloneFlags {
      let givenFlag = cmdLineArgs[1]
      if flag.shortName == givenFlag || flag.longName == givenFlag {
        if cmdLineArgs.count > 2 {
          print("No other options or flags should be used with `\(givenFlag)`")
          self.printUsageAndExit(1)
        }
        parserResult[flag.shortName] = true
        return parserResult
      }
    }

    //read given flag from command line args that are not stand alone and remove the found flag from the array
    for flag in self.flags {
      let givenFlag = cmdLineArgs[1]
      if flag.shortName == givenFlag || flag.longName == givenFlag {
        parserResult[flag.shortName] = givenFlag
        cmdLineArgs.remove(at: 1)
      }
    }

    // At this point the args count should be an odd number
    // the app path is at index 0 of the args. This is what makes it an odd length (size)
    if (cmdLineArgs.count % 2) == 0 { self.printUsageAndExit(1) } 

    // long handed way of using indexes and step thru the array but ensure not to go out of the array bound
    for flag in self.options {
      for num in 1..<cmdLineArgs.count {
        if cmdLineArgs[num] == flag.shortName || cmdLineArgs[num] == flag.longName {
          parserResult[flag.shortName] = cmdLineArgs[num+1]
        }
      }
    }

    // return results hashable
    return parserResult
  }

}
