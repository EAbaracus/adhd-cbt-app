"""Receipt verifier registry. Classes instantiated lazily; tests inject fakes on app.state."""


class AppleReceiptVerifier:
    """Real implementation requires App Store Server API keys — out of M1 scope.
    Raises ValueError on invalid receipt; returns {'active', 'expires_at'} on valid."""

    def verify(self, receipt: str):
        raise NotImplementedError(
            "Apple verification requires store account (spec open item 2)"
        )


class GoogleReceiptVerifier:
    def verify(self, receipt: str):
        raise NotImplementedError(
            "Google verification requires Play account (spec open item 2)"
        )


VERIFIERS = {"apple": AppleReceiptVerifier, "google": GoogleReceiptVerifier}
