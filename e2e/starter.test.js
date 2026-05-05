describe('MonApp E2E Tests', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('devrait afficher l\'écran d\'accueil', async () => {
    await expect(element(by.text(/Welcome to React Native/i))).toBeVisible();
  });

  it('devrait afficher le texte principal', async () => {
    await expect(element(by.text(/Learn once, write anywhere/i))).toBeVisible();
  });

  it('devrait être capable de scroller', async () => {
    await waitFor(element(by.text(/Welcome/i)))
      .toBeVisible()
      .withTimeout(10000);
  });

  it('devrait charger correctement l\'application', async () => {
    await expect(element(by.type('RCTSafeAreaView'))).toBeVisible();
  });
});

