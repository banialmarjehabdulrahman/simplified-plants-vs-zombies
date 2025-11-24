'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "3c52d3929735e14e99e006192286e645",
"assets/AssetManifest.bin.json": "ad3556df214335737dc55a4ff950e1b7",
"assets/assets/audio/music/track1.mp3": "1df492c0a9fd4f5ccbd42c5794ea132e",
"assets/assets/audio/music/track2.mp3": "89ad43f774b35fc46df8e0cc99d859fc",
"assets/assets/audio/music/track3.mp3": "3568039d24347499cacca3e32c1ee4c0",
"assets/assets/audio/sfx/card_click.mp3": "0ccf1d982e14f3461dec99ee214e313b",
"assets/assets/audio/sfx/damage_plant.mp3": "e3e877b1a2f39fe3f3268f1bb6d5c16d",
"assets/assets/audio/sfx/error_no_sun.mp3": "7266a789e76b377fd116e9b63c03e720",
"assets/assets/audio/sfx/game_lost.mp3": "1ce8f36de2a7578c0f8e19d1c5a32240",
"assets/assets/audio/sfx/game_win.mp3": "c7b4ebf4da0be67baa48058ea7125969",
"assets/assets/audio/sfx/huge_wave.mp3": "ced0d5c745808a1e1b0ddc533e9b2483",
"assets/assets/audio/sfx/peashooter_shoot.mp3": "4dd77b36cdcb637c0935c0382050d12e",
"assets/assets/audio/sfx/sunflower_produce.mp3": "6cb115244fe85b76e713b7581ba4ad67",
"assets/assets/audio/sfx/zombie_die.mp3": "2d39bfa0107c1b7eef44ec165aa20306",
"assets/assets/audio/sfx/zombie_hurt0.mp3": "2d39bfa0107c1b7eef44ec165aa20306",
"assets/assets/audio/sfx/zombie_hurt1.mp3": "9675c6f20ae7278463e10dbc8a392754",
"assets/assets/audio/sfx/zombie_hurt2.mp3": "60a9511d776b95190eda5498a48d7c65",
"assets/assets/audio/sfx/zombie_hurt3.mp3": "bbf04c70b0c3697d67679dda3b6c9749",
"assets/assets/audio/sfx/zombie_reach_house.mp3": "dad348712a8df432d2217fee2c2d27fd",
"assets/assets/images/green_tiles/tile_dark_green.png": "2c72769e2098491a7d4aa576ac8b8966",
"assets/assets/images/green_tiles/tile_light_green.png": "b6c790694a7778509fa85df88ae62208",
"assets/assets/images/plants/fast_peashooter_red.png": "a0cedb4026445f73c5f93790ab52a76b",
"assets/assets/images/plants/ice_peashooter_blue.png": "97cf8e9b0c2a958e5387252106d15dcd",
"assets/assets/images/plants/peashooter.png": "3ebdd483dcf2660264063f818ae1a22e",
"assets/assets/images/plants/sunflower.png": "8d13606dc4426bf5291bf36d6ae97d24",
"assets/assets/images/plants/wallnut.png": "fa669dfcf5b18c4b10e1d397617dec84",
"assets/assets/images/plants/walnut_keyframes/walnut_frame_1.png": "f2f7a110897b5883b7dba9064dddbee0",
"assets/assets/images/plants/walnut_keyframes/walnut_frame_2.png": "a7e478e1cc9a93ce46d65def89862189",
"assets/assets/images/plants/walnut_keyframes/walnut_frame_3.png": "94956eee9168625dceb51b47bf92d96a",
"assets/assets/images/plants/walnut_keyframes/walnut_frame_4.png": "ea96c921c8b06e7381fb2dfb2d16b1a7",
"assets/assets/images/ui/heart.png": "db5039d65cf5b11988b6881811e135d5",
"assets/assets/images/ui/sun.png": "f24bcb0b546c863b3e37ba055d9f168d",
"assets/assets/images/zombies/brute_zombie.png": "4e49fc9864e3abe64785a1f406fafdb7",
"assets/assets/images/zombies/crawler_zombie.png": "00194c459f4810793fbc939cf20a0da8",
"assets/assets/images/zombies/ghoul_zombie.png": "6d365e6f9c60ace261b898f1ee9dc3a8",
"assets/assets/images/zombies/runner_zombie.png": "2b9e8beac75334eb269a14f1b148a32b",
"assets/assets/images/zombies/stalker_zombie.png": "9601cb7619f16137a2e34f2f6e03ba0b",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "c0ad29d56cfe3890223c02da3c6e0448",
"assets/NOTICES": "577c167357f41f7e82f515ee41ae9830",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "a2217b51b04bfe6a53b140130c42f5f9",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "b13e01694376c8c4936b1f4254eba524",
"/": "b13e01694376c8c4936b1f4254eba524",
"main.dart.js": "897dd0c9374fff8a07487cec2358b996",
"manifest.json": "ede79c573a0f60464a2640e71c3165fb",
"version.json": "c08628bd0823e0893000e88633bafd8d"};
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
