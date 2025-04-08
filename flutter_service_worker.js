'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "76c6ef504c22d840135a31e653c31f28",
"assets/AssetManifest.bin.json": "d2b0a77d5956f0aa98c8bad8f9dd27dd",
"assets/AssetManifest.json": "a9d32b9ac8433a45c95a64bad6564f1b",
"assets/assets/characters/default/character.png": "56b1d227967d3c7f6cf57f10a848e218",
"assets/assets/characters/default/images/hit_effect.png": "ec43b5cc519203b656cec77b77d27789",
"assets/assets/characters/default/images/hit_effect2.png": "211df9f4aa8119802e2bcad058edeac1",
"assets/assets/characters/default/sounds/coin.wav": "9fc0bfb7653a29a758cd21ddf155e6c4",
"assets/assets/characters/default/sounds/Failed.wav": "3c93e2eea01160fa0eff87e6d4f301ea",
"assets/assets/characters/default/sounds/kick.wav": "88cfe694e19ca1c6e07619768d548665",
"assets/assets/characters/default/sounds/punch.wav": "ceeaeee1d62c2b887ef9c3036afe5d95",
"assets/assets/characters/default/sounds/Stageclear.wav": "51930c211351d46b9ec2b669364433d5",
"assets/assets/characters/default/sounds/victory_sound.wav": "42579bfcb21052b66e8b7b67bf1cd22b",
"assets/assets/characters/samurai/character.png": "ddb4f777c45dd292ee8450ca2a9a630d",
"assets/assets/characters/samurai/effects/sword1.png": "817773ec5d3f5f5d74a5133172de9aaf",
"assets/assets/characters/samurai/effects/sword2.png": "3585a73c1608dd20194717283924881e",
"assets/assets/characters/samurai/effects/sword3.png": "4f6081cddb06c8fda795e48e86920495",
"assets/assets/characters/samurai/effects/sword4.png": "a6d43daff83bb651b5dca32510b1cc3c",
"assets/assets/characters/samurai/effects/sword5.png": "922c4410e157d4e50c52427293bfa854",
"assets/assets/characters/samurai/effects/sword6.png": "72726346eca1b4d0e016f7389079c050",
"assets/assets/characters/samurai/sounds/sword.wav": "146f4fd76195a02c8232b07278566b66",
"assets/assets/characters/samurai/sounds/sword1.wav": "66d0cdf754b333c8ab909eee8681a021",
"assets/assets/characters/samurai/sounds/victory_sound.wav": "42579bfcb21052b66e8b7b67bf1cd22b",
"assets/assets/fonts/MotionControl-Bold.otf": "8088b5b712bb8a803cab3448bb7ab94d",
"assets/assets/images/coin.png": "eea3625968c5a9470f72ae789c8f49d0",
"assets/assets/images/hit_effect.png": "ec43b5cc519203b656cec77b77d27789",
"assets/assets/images/hit_effect2.png": "211df9f4aa8119802e2bcad058edeac1",
"assets/assets/sounds/coin.wav": "9fc0bfb7653a29a758cd21ddf155e6c4",
"assets/assets/sounds/Failed.wav": "3c93e2eea01160fa0eff87e6d4f301ea",
"assets/assets/sounds/kick.wav": "88cfe694e19ca1c6e07619768d548665",
"assets/assets/sounds/punch.wav": "ceeaeee1d62c2b887ef9c3036afe5d95",
"assets/assets/sounds/Stageclear.wav": "51930c211351d46b9ec2b669364433d5",
"assets/assets/sounds/sword.wav": "146f4fd76195a02c8232b07278566b66",
"assets/assets/sounds/sword1.wav": "66d0cdf754b333c8ab909eee8681a021",
"assets/assets/sounds/victory_sound.mp3": "604373c9fe8af4fa0ca994d7dd00e159",
"assets/assets/sounds/victory_sound.wav": "42579bfcb21052b66e8b7b67bf1cd22b",
"assets/FontManifest.json": "75a8d5ce7970a79935558f057d79872c",
"assets/fonts/MaterialIcons-Regular.otf": "c8f7848f843fae774526aa6433f6268b",
"assets/NOTICES": "20821f4c28b214db440392bfbf4bc8bc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "f2551115d4d749fe3685af1134da1b19",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "e4594e89dff9d9412230a97c852caf5c",
"/": "e4594e89dff9d9412230a97c852caf5c",
"main.dart.js": "43819deac5a56c68989ba52506ed15c3",
"manifest.json": "ea82b5ec0749d2383ad03fd586481ddd",
"version.json": "817d6398095eec51e2eb3afeae073486"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
