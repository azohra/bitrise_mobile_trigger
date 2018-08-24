import XCTest
@testable import Trigger

class BitrisePayloadTest: XCTestCase {
    
    //This test is not run on Linux, because on Linux the JSONEncoder swiches the fields in
    //the result JSON and so the test fails as the result JSON string won't be exactly the same
    //as the expectedJSON string.
    func testPayloadObjectConversionToJSON() {
        let hookInfo = HookInformation(type: "bitrise", apiToken: "AVCTRE$3258gyt65")
        let buildParams = BuildParams(
            branch: "azi_branch",
            workflowID: "XcodeForever",
            triggeredBy: "CI",
            environments: [
            [
                "mapped_to": "API_TEST_ENV",
                "value": "This is the test value",
                "is_expand": "true"],
            [
                "mapped_to": "HELP_ENV",
                "value": "$HOME variable contains user's home directory path",
                "is_expand": "false"
            ]])
      
        let hookInfoStr = "\"hook_info\":{\"type\":\"bitrise\",\"api_token\":\"AVCTRE$3258gyt65\"}"
        let triggeredByStr = "\"triggered_by\":\"CI\""
        let branchStr = "\"branch\":\"azi_branch\""
        let workflowIdStr = "\"workflow_id\":\"XcodeForever\""
        let envVarsStr = "\"environments\":[{\"value\":\"This is the test value\",\"mapped_to\":\"API_TEST_ENV\",\"is_expand\":\"true\"},{\"value\":\"$HOME variable contains user\'s home directory path\",\"mapped_to\":\"HELP_ENV\",\"is_expand\":\"false\"}]"
        let buildParamsStr = "\"build_params\":{\(workflowIdStr),\(envVarsStr),\(triggeredByStr),\(branchStr)}"
        let expectedJSON = "{\(hookInfoStr),\(buildParamsStr)}"
      
        let payload = BitrisePayload(apiInfo: hookInfo, params: buildParams)
        let encoder = JSONEncoder()
        
        do {
        let data = try encoder.encode(payload)
            let result = String(data: data, encoding: .utf8)!
            let errorMsg = "result JSON string is not the same as the expected JSON.\nresult: \(result)\nexpectedJSON: \(expectedJSON)"
            XCTAssert(result == expectedJSON, errorMsg)
        } catch {
            XCTAssert(false, "\(error)")
        }
    }
}
