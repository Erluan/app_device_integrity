import CryptoKit
import DeviceCheck
import Foundation

@available(iOS 14.0, *)
final class AppDeviceIntegrity {
    let inputString: String
    var attestationString: String?
    var error: String?
    private let keyName = "AppAttestKeyIdentifier"
    private let attestService = DCAppAttestService.shared
    private var keyID: String?

    init?(challengeString: String) {
        print("init with challengeString", challengeString)
        self.inputString = challengeString

        guard attestService.isSupported else {
            print("[!] Attest service not available")
            return nil
        }
    }

    func generateKeyAndAttest(completion: @escaping (Bool) -> Void) {
        // Generate the key
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
            
            // Proceed with pre-attestation after key generation
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

        let challenge = Data(self.inputString.utf8)
        let hash = Data(SHA256.hash(data: challenge))

        attestService.attestKey(keyID, clientDataHash: hash) { [weak self] attestation, error in
            guard let self = self else { return }

            if let error = error {
                self.error = error.localizedDescription
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
            print("Attestation successful")
            completion(true)
        }
    }
}
