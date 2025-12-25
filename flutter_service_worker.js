'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "ce21d9bbf0313fe4e066c922b159452b",
".git/config": "846e76227612c64c6c94b1a118e9dc1b",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "4cf2d64e44205fe628ddd534e1151b58",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "ae191cbe7e10ac121bfc506dcb220879",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "8557ef0cca806fa67fdd0c45a65a4cfd",
".git/logs/refs/heads/master": "8557ef0cca806fa67fdd0c45a65a4cfd",
".git/logs/refs/remotes/origin/gh-pages": "67a2abe41031d86ab43c3ca3b08e7700",
".git/objects/00/32b0c0e0868ef675ff484c73385abb077ff453": "5f711d722387ae33e8837dbae74abba3",
".git/objects/01/2651547587a0e27e2d8d67603aa4c8a86fe3e4": "d1e7dc8325976de1f9f16081db5b5e60",
".git/objects/01/c5db06232960f039185cf26fb38547e4ffae05": "cf9d43a08791d64db14f801a135f2ba0",
".git/objects/06/5a156ad876ae75d08bca0aabc8c1e01f285abb": "1338ac20d12542d14345378e2fe2be26",
".git/objects/09/8d2fb5851c92236b72f68263cd91886db729b6": "7605759c2a5f639931d24fdc64171045",
".git/objects/0b/08f9b4925ba1286969c12860d57e906199369f": "47c24874a54b87336a4f71e466037f85",
".git/objects/10/9e09162ca13a58688826bdba02799a2807377e": "1cbece680724604d8d9a5827bdb62a2d",
".git/objects/11/574112d47cfc77f04363ca56b6db423e7c3b75": "2231a67bc443c1956f25677e2d93f615",
".git/objects/1c/10972eceaea5bc6ddf055d7e4caa75e01e6f8e": "0185c67dad999f49755704755e660c16",
".git/objects/1d/468b85698a60041b450286f31b3264b3bbd6f7": "5c8c497111befde32ac151f14cf92f85",
".git/objects/20/628161db48880bd3208ef193ef7804ab089a95": "37bf55a69060f3dee9a7bc9b987879b5",
".git/objects/21/85bff862726189e93cb08fcdac54ea1f92ae6f": "22c653517bb04563d95cc0812860e402",
".git/objects/22/5744bd6947df637fa2f5dbcc5e7c0dea0a6aa1": "9a92957b4a8b60d7f510b1a0baaae628",
".git/objects/28/5b0ea1734efd89b0ef5db92d6db6f0103c39d5": "ab417b8d6c4cbcfb5dc165f8e3350df8",
".git/objects/2d/0471ef9f12c9641643e7de6ebf25c440812b41": "d92fd35a211d5e9c566342a07818e99e",
".git/objects/2f/b91dae81326ca0edab65ebdf7fb2450e82e562": "91f889fd3cd67777b9ac9bd25320dc83",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/3b/b0860a0981211a1ab11fced3e6dad7e9bc1834": "3f00fdcdb1bb283f5ce8fd548f00af7b",
".git/objects/3b/eb7890b45ca2875195243c4d7b8090b4f2549e": "7ad1148a6be26d6dc597bf1d110c6ccb",
".git/objects/3f/74879e6b67a8656a488caeb3c1ea10195a49d7": "dee49e58a918c2c4447505e66c12f976",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/45/45b8eaf094b432e53b551486b4dbcd4586844d": "ae8553488dfce048a2bf9bf1333cda81",
".git/objects/49/c7a160e3e67721d5401c92a0201801e9db9059": "f413ccc15fa0c4872c4876813175363d",
".git/objects/4a/5a9fcf851403b7dfc7669c989a6b9fdb5a5ff5": "464521d0ab19d2d614d994cfe05b249d",
".git/objects/4a/6872381b5ae8996e31bfc4b81269d07c4d8690": "fb2b9a84ecf2b67ce00f0616a25c24a6",
".git/objects/4c/b6ae738bb9c944ccc79883e4bebf719bfdfe2e": "b7c05ae50307f2f3936b5171f829e6dc",
".git/objects/54/1ef2bd508d9e176fdc6e54f3ebd30fada508cf": "19023d2d2dd7d1dbccac2d13adbb8271",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/58/9859f5d0639a4d4087045516bf458c1f1663a8": "97f5e3a2261cb9a8ebe8b35200577b4c",
".git/objects/5b/db2a93dd23014dd4271c613a429341df39d4af": "6a2fc24c94a95080cc9e1d05e5bbcb60",
".git/objects/5c/a017893b2927c9a549a678278c883a97ef2a0d": "ae6097befff3fad1d76396cd065264d6",
".git/objects/5c/a4c57829c8403ef7cb80fd4728116bf8f5ca39": "f5133faa881532edd8af65760fe3bbea",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/61/2a54af88cc0438581097aaf5ba326da1dae3db": "d77fdfd5977c6df9d8154106e62cb806",
".git/objects/68/a20a5d3531461e0430cceaf8c617d2cded693b": "e96695472ba23dbebc849a55f9f29d97",
".git/objects/69/7612b856b42c7df2f6b11a751697ce3fb59ba5": "eb2c167bd5d2090211aac5d103a33a2d",
".git/objects/6c/36c6d0c51f0c6a79d27c61c4b3df3ce6ef08ac": "e5f1434d7450ae248791a8517816bf40",
".git/objects/6f/8ecefbbb97538291bf5c568b3041569e1b7168": "7ec807ccc07e38dd4eccef2aa6255757",
".git/objects/70/6b89226856a184964d4ef26acca4690f34feb3": "b47861a6de6336cfde49244ec049778b",
".git/objects/72/3d030bc89a4250e63d16b082affe1998618c3f": "e4299c419434fc51f64a5266659918fa",
".git/objects/72/ada6baac9193047a04d1ef7fc6c08c19a0aad4": "515cf0496f523efb00e1cdbca48aebe4",
".git/objects/72/d2ac11e3a7e709db33c98612eb36324b65a1c5": "c79df3f24627348b03a122af4e1edf89",
".git/objects/75/42c6b0e9cdcf9c8e3f7da12ab5edf7415f9fad": "f31e0e5a82c78b71792ba19b15f96867",
".git/objects/83/1eee736ddb6350818b0ec7450c5b0e8ad47613": "ed7ebc340eab23aa875f9d6f90fd8820",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8f/0e71958376cc07fa7600ed89b0344e60823b86": "5c6d3c912690c09c64d608791407fea0",
".git/objects/8f/c8be62f202c40e7d3e2e16242fb065cfc4e1a7": "6fda1b80da67a8d96186cf8ab8b24087",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/9e/e1919dc230d3433cce79d137c37081c974034a": "7918dcf5b15c1ac607255918935ca48a",
".git/objects/a5/6f37fc6d574035afe177db5ba91ee3c5006e39": "3e40f855ba6d2279e67aa8d472a7f5ad",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/a9/91f51138ffe059d588003dc7936aff059a0428": "b73a35563fa129bd884d8b5c53ee9231",
".git/objects/ad/22898a92f6f287d5596c719a9939607af0dc61": "822502e68afa7746bf46d4a0c6c68af8",
".git/objects/ad/2f90b78480aeb6608226d9db4ecbd3ec06aaeb": "4add97a99941aa0e9eed0f2173416ade",
".git/objects/af/3d4d7339e2c0d1e7ac6bd2a8caff3ce8f6a099": "40391196b15bd50753047472e0d388e6",
".git/objects/b2/0572f116e3d41bd010ad139fb1a5bd6260d7ed": "ee9c7776cce671d6a5a88827441c1be9",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/bc/7d993f94baf32ca11e5f5dc5412aac12a668a9": "d782f8a82d795ae96da7df117f4c51bd",
".git/objects/be/0ab09e7237378daa4f214b294c21eaa3e9ae34": "1eb02e15bf813847ccbd18128cec695d",
".git/objects/c3/6629fa5cb2d820e42e668b2dcb2b7987a5d923": "8f32faa8ce4fd420a62c9321c8219ede",
".git/objects/c3/944b8a86e8e765015d9f823da8321bc425b40f": "00f2a42df0979a2759e789cb2c87b344",
".git/objects/c7/7663172ca915a99a594ca17d06f527db05657d": "6335b074b18eb4ebe51f3a2c609a6ecc",
".git/objects/ca/28c42816e1ba98b5202e9a751a7a71c42d96e6": "963cafb9d7043e8a4b08248318128b18",
".git/objects/cc/556fd90d43d461b155c0de63c0836197851b67": "c983d0fe54d8095434d931db23840b93",
".git/objects/cc/fab74c1f56c330985060e2247607eaedb3c7d7": "ad5b6117df489509af208438785f208b",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/de/7d97a0987d908e3a7e636dcc033376ccfc70cc": "ab71005af8bc71c289f1bd8c3579a3ae",
".git/objects/e1/3088b5de7d73320648cdcc0caf0e39f44054c5": "fea3e8eaba2e93f3bf292674b8efac0f",
".git/objects/e3/893d874f83726c7faee6b44a20e3f501a947cf": "018c2070207c5adf1a0677acd0bd09fc",
".git/objects/e9/008cae4fa8da95de581a37e4177afea0b846d1": "015e9b13c12a9b6b97f2b893f765b256",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ed/4d5018f04c58b73b44bccd0844e7f6a19b92b1": "a13a0936d2166839531d7d566f0be4ca",
".git/objects/ee/8b72f51015219cecd5478a024d9511be2fc18d": "25d1fb7a0403804df9cd7dac17f434c5",
".git/objects/ee/da440f24c957cb4033ff73f42fe86efc5dbdd4": "1b39c65de96dbc2132db71f85ac8a340",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f6/cc06a0d471df5df1f35082b09b45fced798d05": "b3ed116bd3c82d600d635270058f4345",
".git/objects/f8/aacd093a08e534b20da1913980c8152f43417b": "56771104f338dd71884b65605947eb85",
".git/objects/fb/ea8db1655ca4eb3197f4f3608770aad694eb16": "ac87610a48f84b82e1baeb047dcf6b87",
".git/objects/fc/b85228e5a48abfb459068e166011d9a69f2cf8": "f4ad44eed21549d8eca2343359ceed56",
".git/objects/fd/522b2875785be128a1d38ca7a1b760f86af20a": "98340fc99e8227d81316d234b8547c35",
".git/objects/fd/a9319df1a7f22fe4f1304d6b5b0c7852497b92": "5effa673b8ea2dba42a077686309ffa8",
".git/objects/fd/ce53bf14fb3a40d6dd68bcc2d95fe74a9acaeb": "ab4bcb9cca3b1f92e58ebe11672d208b",
".git/objects/fe/6c54affdcf37187ddf84dd6b4ddd6e9c4329bb": "0a1c263733e5a34bcb49322544ceb5a3",
".git/refs/heads/master": "dcdd034592a4ab21fc217947b6e24390",
".git/refs/remotes/origin/gh-pages": "dcdd034592a4ab21fc217947b6e24390",
"assets/AssetManifest.bin": "13e9c7d765003a4c446de0eb20ad8668",
"assets/AssetManifest.bin.json": "45d249adfb890b91c6255722647b5cb6",
"assets/AssetManifest.json": "c38b90a5eb2137085f496581fc117ed4",
"assets/assets/images/8666551_play_circle_icon.png": "0908d64f9f521172e4713044f975711d",
"assets/assets/images/book.png": "53d523dc31337a65f3f7938ea78e625c",
"assets/assets/images/default_avatar.png": "d0a8e0c9d065d01f3e765d833eff6ad0",
"assets/assets/images/image-error.png": "d92c3b396abfd61ace753ac1ada50522",
"assets/assets/images/itqan_logo.png": "8c40241fe772821f6a83c806f2a26848",
"assets/assets/images/whatsapp.png": "1af173de3bd16adb1613a275e38fa838",
"assets/FontManifest.json": "e0b306db1b5fc2b3916837b4126d8036",
"assets/fonts/Cairo/Cairo-VariableFont_slnt,wght.ttf": "d5664f46ff376cb597c2e18ec22f9b38",
"assets/fonts/Cairo/static/Cairo-Bold.ttf": "ad486798eb3ea4fda12b90464dd0cfcd",
"assets/fonts/MaterialIcons-Regular.otf": "b7ecae1fd8b6fa8dc46f9a70ab27af17",
"assets/NOTICES": "c14d5cf000bb98e96fdda0d2cf62d975",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "d7d83bd9ee909f8a9b348f56ca7b68c6",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "8df3c8dcf9e93ad152b972e52b8ba00d",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "262525e2081311609d1fdab966c82bfc",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "269f971cec0d5dc864fe9ae080b19e23",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/youtube_player_flutter/assets/speedometer.webp": "50448630e948b5b3998ae5a5d112622b",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "8c40241fe772821f6a83c806f2a26848",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "7fee4b9f9bca3fcbff4fe4d0a66ca61e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "c656f3e0281b2de5b4a6d5347cb22c0e",
"/": "c656f3e0281b2de5b4a6d5347cb22c0e",
"main.dart.js": "892d08f09ee7624a26e2625f8e098ca3",
"manifest.json": "e8137bebd7c076432a580c019ac04923",
"splash/img/dark-1x.png": "0445131b45a6c585a5618a2065f83480",
"splash/img/dark-2x.png": "924be1856e588acdea97f5d6a22b6eb6",
"splash/img/dark-3x.png": "4f6df5809e03c80c055167289969e58e",
"splash/img/dark-4x.png": "9a6919a413c3757a3ec08eab37289c8a",
"splash/img/light-1x.png": "0445131b45a6c585a5618a2065f83480",
"splash/img/light-2x.png": "924be1856e588acdea97f5d6a22b6eb6",
"splash/img/light-3x.png": "4f6df5809e03c80c055167289969e58e",
"splash/img/light-4x.png": "9a6919a413c3757a3ec08eab37289c8a",
"version.json": "dc9033675eb80e179d75db7b245a9e66"};
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
