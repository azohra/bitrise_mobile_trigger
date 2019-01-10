import Foundation

#if os(Linux)
import Glibc
setbuf(stdout, nil)
#endif

import CLI
import Trigger

var parser = Parser()
parser.usage("Usage: bitriseTrigger [flags] [options]")

parser.option("-w", "--workflow-id", "WORKFLOW_ID", "Bitrise workflow id.")
parser.option("-b", "--branch", "BRANCH_NAME", "Name of the branch to be built.")
parser.option(
  "-c",
  "--config",
  "CONFIG_PATH",
  "Absolute path of to configuration file."
)
parser.option(
  "-e",
  "--env",
  "ENVIRONMENT_VARIABLE=VALUE",
  "List of environment variables to be passed e.g. key1=value1,key2=value2"
)

parser.helpFlag("-h", "--help", "Prints this help message")
parser.flag("-V", "--version", "Version of cli running.", standAlone: true)

let cliMap = parser.parse(&CommandLine.arguments)
if cliMap["-V"] != nil {
  print("Trigger version: ", App.version.rawValue)
  exit(0)
}

guard let configPath = cliMap["-c"] as? String else {
    print("You must supply a path to a config file - config.json - to be used for project configuration.")
    exit(1)
}

// Read the config file and create config object
let json: Data
do {
  json = try Config.readConfigFile(path: configPath)
} catch {
  print(error)
  exit(1)
}

let projectConfig: Config
do {
  projectConfig = try Config(with: json)
} catch {
  print(error)
  exit(1)
}

// create bitrise client object
var bitriseClient = BitriseClient(projectConfig: projectConfig)

// --------------------------------------------------------------------------------------------
// using input data

// TODO: implement logging level, e.g. Logging.level = log_level

// --------------------------------------------------------------------------------------------
// hit bitrise api to trigger the build and parse response
if let branch = cliMap["-b"] as? String, let workflowId = cliMap["-w"] as? String {
  let (response, responseError) = bitriseClient.triggerWorkflow(
    branch: branch,
    workflowId: workflowId,
    envs: cliMap["-e"] as? String
  )
    
  guard let triggerResponse = response else {
    print("!ERROR:", responseError!)
    exit(1)
  }
    
  if triggerResponse.status != "ok" {
    print(":> API call to trigger Bitrise did NOT return with `ok` status. Trigger failed.")

    if let slackURL = projectConfig.slackURL {
      switch SlackClient(slackURL: slackURL)
        .sendTriggerFailedMessageToSlack(planName: "Bitrise Plan Name goes here", workflowId: "UnitTest") {
      case .success:
        print("error message sent to slack")
      case .failure:
        print("Could not reach slack to give error message that trigger failed")
      }
    }

     exit(1)
  }

  print(":> Waiting on build...")

  let buildURL = triggerResponse.buildURL
  let buildSlug = triggerResponse.buildSlug
  var buildStatus: Int = 0
  var previousBuildStatusText: String?
  var wasStartTimePrinted = false
    
  print("Build URL: ", buildURL)
   // TODO: Implement a timeout capability
  
  while buildStatus == 0 {
    sleep(5)
    guard let res = bitriseClient.checkBuildStatus(slug: buildSlug) else {
        print(":!ERROR - checkBuildStatus returned nil")
        exit(1)
    }
    let currentBuildStatusText = res.data.statusText
    if previousBuildStatusText != currentBuildStatusText {
        print("Build", res.data.statusText)
        previousBuildStatusText = currentBuildStatusText
    }
    buildStatus = res.data.status
    if let buildStartTime = res.data.startedOnWorkerAt, !wasStartTimePrinted {
       let date = DateConverter.convert(from: buildStartTime)
       print("Build start time: ", date)
       wasStartTimePrinted = true
    }
  }
    
  // Fetch the build logs
  var logIsArchived = false
  var responseFromGetLogInfo: BitriseLogInfoResponse?

  while !logIsArchived {
    sleep(5)
    responseFromGetLogInfo = bitriseClient.getLogInfo(slug: buildSlug)
    guard let response = responseFromGetLogInfo else {
      print(":!ERROR - getLogInfo returned nil")
      exit(1)
    }
    logIsArchived = response.isArchived
  }

  let logs = bitriseClient.getLogs(from: responseFromGetLogInfo!)
  if let logs = logs {
    // Append the build logs to stdout
    print("================================================================================")
    print("============================== Bitrise Logs Start ==============================")
    print(logs)
    print("================================================================================")
    print("==============================  Bitrise Logs End  ==============================")
  } else {
    print("LOGS WERE NOT AVAILABLE - go to \(buildURL) to see log.")
  }

  let msg = bitriseClient.buildStatusMessage(buildStatus)
  print(msg)

  let success = buildStatus == 1
  let exitCode: Int32 = success ? 0 : 1
  exit(exitCode)
}
