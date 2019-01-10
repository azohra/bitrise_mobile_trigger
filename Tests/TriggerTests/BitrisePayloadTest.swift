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
        //order of the fields in the Json string produced using the JSONEncoder() changes.
        //Below are the two possible outputs:
        let envVarsStr1 = """
        \"environments\":[{\"mapped_to\":\"API_TEST_ENV\",\"value\":\"This is the test value\",\"is_expand\":\"true\"},{\"mapped_to\":\"HELP_ENV\",\"value\":\"$HOME variable contains user\'s home directory path\",\"is_expand\":\"false\"}]
        """
        let envVarsStr2 = """
        \"environments\":[{\"value\":\"This is the test value\",\"mapped_to\":\"API_TEST_ENV\",\"is_expand\":\"true\"},{\"value\":\"$HOME variable contains user\'s home directory path\",\"mapped_to\":\"HELP_ENV\",\"is_expand\":\"false\"}]
        """
        let buildParamsStr1 = "\"build_params\":{\(workflowIdStr),\(envVarsStr1),\(triggeredByStr),\(branchStr)}"
        let buildParamsStr2 = "\"build_params\":{\(workflowIdStr),\(envVarsStr2),\(triggeredByStr),\(branchStr)}"
        let expectedJSON1 = "{\(hookInfoStr),\(buildParamsStr1)}"
        let expectedJSON2 = "{\(hookInfoStr),\(buildParamsStr2)}"
        let payload = BitrisePayload(apiInfo: hookInfo, params: buildParams)
        let encoder = JSONEncoder()
        
        do {
        let data = try encoder.encode(payload)
            let result = String(data: data, encoding: .utf8)!
            let errorMsg = """
            result JSON string is not the same as the expected JSON.\n
            Result: \(result)\n
            ExpectedJSON: \(expectedJSON1) \n
            or:\n
            \(expectedJSON2)
            """
            XCTAssert((result == expectedJSON1 || result == expectedJSON2), errorMsg)
        } catch {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testTriggerRaisesErrorForWrongEnvironmenVariablesFormat() {
        let branch = "myBranch"
        let workflow = "testWorkflow"
        let environmentVariables = "targetBranch:develop"
        let expectedErrorMessage = "badKeyValueFormat(\"key-value pairs should be passed in the form of key=value\")"
        let expectedErrorType = "TriggerError"
        let (result, error) = BitriseClient().triggerWorkflow(branch: branch, workflowId: workflow, envs: environmentVariables)
        let errorMsg = """
        Result error is not the same as the expected error.\n
        Result error -> \(String(describing: type(of: error!))): \(error!)\n
        Expected error -> \(expectedErrorType): \(expectedErrorMessage) \n
        """
        XCTAssert( String(describing: type(of: error!)) == "TriggerError" &&
                   String(describing: error!) == expectedErrorMessage, errorMsg )

    }
    
    
    static var allTests = [
        ("testTriggerRaisesErrorForWrongEnvironmenVariablesFormat", testTriggerRaisesErrorForWrongEnvironmenVariablesFormat)
    ]
}
