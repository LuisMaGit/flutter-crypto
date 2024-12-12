# Zero Packages Crypto Tracker
## Crypto tracker Flutter app with zero packages consuming the [CoinGecko](https://www.coingecko.com/) api. 

This application collects the historical and current prices (in some fiat currencies) of the most popular cryptocurrencies with graphic display.

Be sure to leave a star :sweat_smile:.

https://user-images.githubusercontent.com/70621340/119499926-1260cd80-bd1c-11eb-8b67-be82a52ec316.mp4

<p float="left">
  <img width="200" height="360" src="https://user-images.githubusercontent.com/70621340/119414434-69c35700-bca4-11eb-95a7-e9509dc86641.jpg">
  <img width="200" height="360" src="https://user-images.githubusercontent.com/70621340/119414439-6b8d1a80-bca4-11eb-8d86-b3082f47ca38.jpg">
  <img width="200" height="360" src="https://user-images.githubusercontent.com/70621340/119500953-38d33880-bd1d-11eb-900d-323d6121f40e.jpg">
</p>

### Features:
* MVVM architecture: Based on inherited widget for state control in the view models.
* Render Object: The graph is a <code>LeafRenderObjectWidget</code>.
* Animations.
* Dark and light mode.
* Streams.

### Configuration:
1. Obtain your [CoinGecko Free Api Key](https://docs.coingecko.com/reference/setting-up-your-api-key),
2. Navigate to <code>lib/data/crypto_data_service/crypto_data_api_contracts.dart</code> and copy the key where it says <code>'YOUR_API_KEY_HERE'</code>.
3. Run the app.






