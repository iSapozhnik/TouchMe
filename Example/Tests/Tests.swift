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
        let pinProtected = PinAuthenticationProtectedWithData()
        let biometricHandler = BiometricHandler<PinAuthenticationProtectedWithData>(authProvider: biometricProvider)
        biometricHandler.authenticateAndGetData(with: pinProtected) { result in
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

    func testBiometricHandler_protectedData_read_error() {
        let expectation = XCTestExpectation(description: "BiometricHandler authenticateAndGetData")

        var biometricProvider: BiometricAuthentication
        if #available(iOS 11.0, *) {
            biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext_notAvailable())
        } else {
            biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext())
        }
        let pinProtected = PinAuthenticationProtectedWithData()
        let biometricHandler = BiometricHandler<PinAuthenticationProtectedWithData>(authProvider: biometricProvider)
        biometricHandler.authenticateAndGetData(with: pinProtected) { result in
            switch result {
            case .failure(let error):
                expectation.fulfill()
                XCTAssertTrue(error == BiometricError.noBiometricAvailable, "BiometricHandler: authenticateAndGetData should return an error")
            default:
                expectation.fulfill()
                XCTFail("No error returned")
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
        let expectation = XCTestExpectation(description: "BiometricHandler evaluatePolicy_successful")

        let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext())
        biometricProvider.evaluatePolicy { error in
            expectation.fulfill()
            XCTAssertTrue(error == nil, "biometricProvider evaluatePolicy failed with error \(error?.localizedDescription)")
        }
        wait(for: [expectation], timeout: 1.0)

    }

    /* I need to find a proper way to mock errors :(
    func testBiometricProvider_evaluatePolicy_failure() {
        let biometricProvider = BiometricAuthenticaticationProvider(with: TouchMeLAContext(with: MockError()))
        biometricProvider.evaluatePolicy { error in
            XCTAssertTrue(error == nil, "biometricProvider evaluatePolicy should return an error")
        }
    }
    */

    func testErrorCodes() {
        var code = -1
        var error = BiometricError.initWithError(errorWithCode(code))
        XCTAssert(error == .authenticationFailed, "Pass \(error)")

        code -= 1
        error = BiometricError.initWithError(errorWithCode(code))
        XCTAssert(error == .userCancel, "Pass \(error)")

        code -= 1
        error = BiometricError.initWithError(errorWithCode(code))
        XCTAssert(error == .userFallback, "Pass \(error)")

        code -= 1
        error = BiometricError.initWithError(errorWithCode(code))
        XCTAssert(error == .systemCancel, "Pass \(error)")

        code -= 1
        error = BiometricError.initWithError(errorWithCode(code))
        XCTAssert(error == .passcodeNotSet, "Pass \(error)")

        code -= 1
        error = BiometricError.initWithError(errorWithCode(code))
        XCTAssert(error == .biometryNotAvailable, "Pass \(error)")

        code -= 1
        error = BiometricError.initWithError(errorWithCode(code))
        XCTAssert(error == .biometryNotEnrolled, "Pass \(error)")

        code -= 1
        error = BiometricError.initWithError(errorWithCode(code))
        XCTAssert(error == .biometryLockout, "Pass \(error)")
    }

    private func errorWithCode(_ code: Int) -> LAError {
        return LAError.init(_nsError: NSError.init(domain: "domain", code: code, userInfo: nil))
    }
}
