import CryptoKit
import DeviceCheck
import Foundation

final class AppDeviceIntegrity {
    let inputString: String
    var attestationString: String?
    private let keyName = "AppAttestKeyIdentifier"
    private let attestService = DCAppAttestService.shared
    private var keyID: String?

    init?(challengeString: String) {
        self.inputString = challengeString

        guard attestService.isSupported else {
            print("[!] Attest service not available")
            return nil
        }
    }

    init?(keyID: String) {
        self.inputString = ""
        self.keyID = keyID

        guard attestService.isSupported else {
            print("[!] Attest service not available")
            return nil
        }
    }

    func generateKeyAndAttest(completion: @escaping (Bool) -> Void) {
        attestService.generateKey { [weak self] keyIdentifier, error in
            guard let self = self else { return }

            if let error = error {
                print("Key generation error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let keyIdentifier = keyIdentifier else {
                print("Failed to generate key identifier")
                completion(false)
                return
            }

            self.keyID = keyIdentifier
            self.preAttestation(completion: completion)
        }
    }

    func keyIdentifier() -> String {
        return ("\(self.keyID ?? "Error in Key ID")")
    }

    // Pre-attestation process
    private func preAttestation(completion: @escaping (Bool) -> Void) {
        guard let keyID = self.keyID else {
            print("No key ID available for attestation")
            completion(false)
            return
        }

        // Decode Base64URL challenge to Data if input is Base64URL encoded
        let challengeData: Data
        if let base64Data = Data(base64Encoded: inputString) {
            challengeData = base64Data
        } else {
            challengeData = Data(inputString.utf8)
        }

        // let challenge = Data(self.inputString.utf8)
        let hash = Data(SHA256.hash(data: challengeData))

        attestService.attestKey(keyID, clientDataHash: hash) { [weak self] attestation, error in
            guard let self = self else { return }

            if let error = error {
                print("Attestation error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let attestationObject = attestation else {
                print("No attestation object received")
                completion(false)
                return
            }

            self.attestationString = attestationObject.base64EncodedString()
            print("Attestation successful", attestationObject)
            completion(true)
        }
    }

    // Generate assertion for an existing key
    // clientData: Raw client data string that will be hashed with SHA256
    func generateAssertion(clientData: String, completion: @escaping (String?, Error?) -> Void) {
        guard let keyID = self.keyID else {
            let error = NSError(
                domain: "AppDeviceIntegrity",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No key ID available for assertion"]
            )
            completion(nil, error)
            return
        }

        // Decode Base64URL challenge to Data if input is Base64URL encoded
        let clientDataBytes: Data
        if let base64Data = Data(base64Encoded: clientData) {
            clientDataBytes = base64Data
        } else {
            clientDataBytes = Data(clientData.utf8)
        }

        // Convert client data to Data and hash it with SHA256
        let clientDataHash = Data(SHA256.hash(data: clientDataBytes))

        // Verify hash is at least 16 bytes as per Apple documentation
        guard clientDataHash.count >= 16 else {
            let error = NSError(
                domain: "AppDeviceIntegrity",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Client data too short - SHA256 hash must be at least 16 bytes"]
            )
            completion(nil, error)
            return
        }

        attestService.generateAssertion(keyID, clientDataHash: clientDataHash) { assertion, error in
            if let error = error {
                print("Assertion generation error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let assertionData = assertion else {
                let error = NSError(
                    domain: "AppDeviceIntegrity",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "No assertion data received"]
                )
                completion(nil, error)
                return
            }

            let assertionString = assertionData.base64EncodedString()
            print("Assertion generated successfully", assertionString)
            completion(assertionString, nil)
        }
    }
}
