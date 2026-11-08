/// Backend contract (from the architecture spec). The app currently runs on [MockApi]
/// through AppState; replace with an HTTP implementation when the backend is ready.
abstract class Api {
  Future<void> sendOtp(String mobile, {required bool legal}); // POST /auth/otp
  Future<String> verifyOtp(String mobile, String code); // POST /auth/verify -> token
  Future<void> submitKyc(Map<String, String> data); // POST /parties/{id}/kyc
  Future<void> signConsent(String partner); // POST /consents
  Future<void> revokeConsent(String partner); // DELETE /consents/{id}
  Future<void> submitPlantRequest(String plantId); // POST /plants/{id}/request
  Future<void> setStorageConfig(String plantId, double kwh, List<String> circuits); // PUT /plants/{id}/storage-config
  Future<void> acceptChannel(String recommendationId); // POST /channel-recommendations/{id}/accept
  Future<void> signContract(String plantId, String otp); // POST /contracts
  Future<bool> pairDevice(String serial, String dongle); // POST /devices/pair
  Future<void> requestAdvance(String invoiceId, double amount, String otp); // POST /invoices/{id}/advance
  Future<void> cashOut(double amount, String idempotencyKey, String otp); // POST /wallet/cashouts
  Future<void> confirmFinancePlan(String option); // POST /finance/plans
  Future<void> approveWorkOrder(String id); // POST /work-orders/{id}/approve
}

const demoOtp = '123456';
