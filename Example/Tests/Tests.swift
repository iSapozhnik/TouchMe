import XCTest
import TouchMe
import LocalAuthentication

struct MockError: Error {}

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - Biometric Handler
    func testBiometricHandler_biometricIDavailable() {
        let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext())
        let biometricHandler = BiometricHandler(authProvider: biometricProvider, authProtected: PinAuthenticationProtectedWithData())
        XCTAssertTrue(biometricHandler.biometricIDAvailable, "BiometricHandler: biometricIDAvailable not available")
    }

    func testBiometricHandler_protectedData_available() {
        let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext())
        let biometricHandler = BiometricHandler(authProvider: biometricProvider, authProtected: PinAuthenticationProtectedWithData())
        XCTAssert(biometricHandler.protectedDataAvailable, "Pass")
    }

    func testBiometricHandler_protectedData_notAvailable() {
        let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext())
        let biometricHandler = BiometricHandler(authProvider: biometricProvider, authProtected: PinAuthenticationProtectedWithoutData())
        XCTAssert(!biometricHandler.protectedDataAvailable, "Pass")
    }

    func testBiometricHandler_protectedData_read() {
        let expectation = XCTestExpectation(description: "BiometricHandler authenticateAndGetData")

        let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext())
        let biometricHandler = BiometricHandler(authProvider: biometricProvider, authProtected: PinAuthenticationProtectedWithData())
        biometricHandler.authenticateAndGetData { result in
            switch result {
            case .success(let data):
                expectation.fulfill()
                XCTAssertTrue(data == Config.expectedPinString, "BiometricHandler: authenticateAndGetData returned \(data), expected \(Config.expectedPinString)")
            default:
                expectation.fulfill()
                XCTFail("BiometricHandler: authenticateAndGetData error occured")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Biometric Provider
    func testBiometricProvider_availableType_notAvailable() {
        if #available(iOS 11.0, *) {
            let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext_notAvailable())
            XCTAssert(biometricProvider.availableBiometricType == .notAvailable, "Pass")
        }
    }

    func testBiometricProvider_availableType_faceID() {
        if #available(iOS 11.0, *) {
            let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext_faceID())
            XCTAssert(biometricProvider.availableBiometricType == .faceID, "Pass")
        }
    }

    func testBiometricProvider_availableType_touchID() {
        if #available(iOS 11.0, *) {
            let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext_touchID())
            XCTAssert(biometricProvider.availableBiometricType == .touchID, "Pass")
        }
    }

    func testBiometricProvider_evaluatePolicy_successful() {
        let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext())
        biometricProvider.evaluatePolicy { error in
            XCTAssertTrue(error == nil, "biometricProvider evaluatePolicy failed with error \(error?.localizedDescription)")
        }
    }

    /* I need to find a proper way to mock errors :(
    func testBiometricProvider_evaluatePolicy_failure() {
        let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext(with: MockError()))
        biometricProvider.evaluatePolicy { error in
            XCTAssertTrue(error == nil, "biometricProvider evaluatePolicy should return an error")
        }
    }
    */

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
}
