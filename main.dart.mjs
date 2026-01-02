// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It should return a JS Array containing 2 elements. The first
  //   should be the bytes for the wasm module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The second
  //   should be the result of using the JS 'import' API on the js file path.
  async instantiate(additionalImports, {loadDeferredWasm, loadDynamicModule} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _3: (o, t) => typeof o === t,
      _4: (o, c) => o instanceof c,
      _5: o => Object.keys(o),
      _8: (o, a) => o + a,
      _35: () => new Array(),
      _36: x0 => new Array(x0),
      _38: x0 => x0.length,
      _40: (x0,x1) => x0[x1],
      _41: (x0,x1,x2) => { x0[x1] = x2 },
      _43: x0 => new Promise(x0),
      _45: (x0,x1,x2) => new DataView(x0,x1,x2),
      _47: x0 => new Int8Array(x0),
      _48: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _49: x0 => new Uint8Array(x0),
      _51: x0 => new Uint8ClampedArray(x0),
      _53: x0 => new Int16Array(x0),
      _55: x0 => new Uint16Array(x0),
      _57: x0 => new Int32Array(x0),
      _59: x0 => new Uint32Array(x0),
      _61: x0 => new Float32Array(x0),
      _63: x0 => new Float64Array(x0),
      _65: (x0,x1,x2) => x0.call(x1,x2),
      _70: (decoder, codeUnits) => decoder.decode(codeUnits),
      _71: () => new TextDecoder("utf-8", {fatal: true}),
      _72: () => new TextDecoder("utf-8", {fatal: false}),
      _73: (s) => +s,
      _74: x0 => new Uint8Array(x0),
      _75: (x0,x1,x2) => x0.set(x1,x2),
      _76: (x0,x1) => x0.transferFromImageBitmap(x1),
      _78: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._78(f,arguments.length,x0) }),
      _79: x0 => new window.FinalizationRegistry(x0),
      _80: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _81: (x0,x1) => x0.unregister(x1),
      _82: (x0,x1,x2) => x0.slice(x1,x2),
      _83: (x0,x1) => x0.decode(x1),
      _84: (x0,x1) => x0.segment(x1),
      _85: () => new TextDecoder(),
      _86: (x0,x1) => x0.get(x1),
      _87: x0 => x0.buffer,
      _88: x0 => x0.wasmMemory,
      _89: () => globalThis.window._flutter_skwasmInstance,
      _90: x0 => x0.rasterStartMilliseconds,
      _91: x0 => x0.rasterEndMilliseconds,
      _92: x0 => x0.imageBitmaps,
      _196: x0 => x0.stopPropagation(),
      _197: x0 => x0.preventDefault(),
      _199: x0 => x0.remove(),
      _200: (x0,x1) => x0.append(x1),
      _201: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _246: x0 => x0.unlock(),
      _247: x0 => x0.getReader(),
      _248: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _249: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _250: (x0,x1) => x0.item(x1),
      _251: x0 => x0.next(),
      _252: x0 => x0.now(),
      _253: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._253(f,arguments.length,x0) }),
      _254: (x0,x1) => x0.addListener(x1),
      _255: (x0,x1) => x0.removeListener(x1),
      _256: (x0,x1) => x0.matchMedia(x1),
      _257: (x0,x1) => x0.revokeObjectURL(x1),
      _258: x0 => x0.close(),
      _259: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _260: x0 => new window.ImageDecoder(x0),
      _261: x0 => ({frameIndex: x0}),
      _262: (x0,x1) => x0.decode(x1),
      _263: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._263(f,arguments.length,x0) }),
      _264: (x0,x1) => x0.getModifierState(x1),
      _265: (x0,x1) => x0.removeProperty(x1),
      _266: (x0,x1) => x0.prepend(x1),
      _267: x0 => new Intl.Locale(x0),
      _268: x0 => x0.disconnect(),
      _269: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._269(f,arguments.length,x0) }),
      _270: (x0,x1) => x0.getAttribute(x1),
      _271: (x0,x1) => x0.contains(x1),
      _272: (x0,x1) => x0.querySelector(x1),
      _273: x0 => x0.blur(),
      _274: x0 => x0.hasFocus(),
      _275: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _276: (x0,x1) => x0.hasAttribute(x1),
      _277: (x0,x1) => x0.getModifierState(x1),
      _278: (x0,x1) => x0.createTextNode(x1),
      _279: (x0,x1) => x0.appendChild(x1),
      _280: (x0,x1) => x0.removeAttribute(x1),
      _281: x0 => x0.getBoundingClientRect(),
      _282: (x0,x1) => x0.observe(x1),
      _283: x0 => x0.disconnect(),
      _284: (x0,x1) => x0.closest(x1),
      _707: () => globalThis.window.flutterConfiguration,
      _709: x0 => x0.assetBase,
      _714: x0 => x0.canvasKitMaximumSurfaces,
      _715: x0 => x0.debugShowSemanticsNodes,
      _716: x0 => x0.hostElement,
      _717: x0 => x0.multiViewEnabled,
      _718: x0 => x0.nonce,
      _720: x0 => x0.fontFallbackBaseUrl,
      _730: x0 => x0.console,
      _731: x0 => x0.devicePixelRatio,
      _732: x0 => x0.document,
      _733: x0 => x0.history,
      _734: x0 => x0.innerHeight,
      _735: x0 => x0.innerWidth,
      _736: x0 => x0.location,
      _737: x0 => x0.navigator,
      _738: x0 => x0.visualViewport,
      _739: x0 => x0.performance,
      _741: x0 => x0.URL,
      _743: (x0,x1) => x0.getComputedStyle(x1),
      _744: x0 => x0.screen,
      _745: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._745(f,arguments.length,x0) }),
      _746: (x0,x1) => x0.requestAnimationFrame(x1),
      _751: (x0,x1) => x0.warn(x1),
      _753: (x0,x1) => x0.debug(x1),
      _754: x0 => globalThis.parseFloat(x0),
      _755: () => globalThis.window,
      _756: () => globalThis.Intl,
      _757: () => globalThis.Symbol,
      _758: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _760: x0 => x0.clipboard,
      _761: x0 => x0.maxTouchPoints,
      _762: x0 => x0.vendor,
      _763: x0 => x0.language,
      _764: x0 => x0.platform,
      _765: x0 => x0.userAgent,
      _766: (x0,x1) => x0.vibrate(x1),
      _767: x0 => x0.languages,
      _768: x0 => x0.documentElement,
      _769: (x0,x1) => x0.querySelector(x1),
      _772: (x0,x1) => x0.createElement(x1),
      _775: (x0,x1) => x0.createEvent(x1),
      _776: x0 => x0.activeElement,
      _779: x0 => x0.head,
      _780: x0 => x0.body,
      _782: (x0,x1) => { x0.title = x1 },
      _785: x0 => x0.visibilityState,
      _786: () => globalThis.document,
      _787: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._787(f,arguments.length,x0) }),
      _788: (x0,x1) => x0.dispatchEvent(x1),
      _796: x0 => x0.target,
      _798: x0 => x0.timeStamp,
      _799: x0 => x0.type,
      _801: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _807: x0 => x0.baseURI,
      _808: x0 => x0.firstChild,
      _812: x0 => x0.parentElement,
      _814: (x0,x1) => { x0.textContent = x1 },
      _815: x0 => x0.parentNode,
      _816: x0 => x0.nextSibling,
      _817: (x0,x1) => x0.removeChild(x1),
      _818: x0 => x0.isConnected,
      _826: x0 => x0.clientHeight,
      _827: x0 => x0.clientWidth,
      _828: x0 => x0.offsetHeight,
      _829: x0 => x0.offsetWidth,
      _830: x0 => x0.id,
      _831: (x0,x1) => { x0.id = x1 },
      _834: (x0,x1) => { x0.spellcheck = x1 },
      _835: x0 => x0.tagName,
      _836: x0 => x0.style,
      _838: (x0,x1) => x0.querySelectorAll(x1),
      _839: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _840: (x0,x1) => { x0.tabIndex = x1 },
      _841: x0 => x0.tabIndex,
      _842: (x0,x1) => x0.focus(x1),
      _843: x0 => x0.scrollTop,
      _844: (x0,x1) => { x0.scrollTop = x1 },
      _845: x0 => x0.scrollLeft,
      _846: (x0,x1) => { x0.scrollLeft = x1 },
      _847: x0 => x0.classList,
      _849: (x0,x1) => { x0.className = x1 },
      _851: (x0,x1) => x0.getElementsByClassName(x1),
      _852: x0 => x0.click(),
      _853: (x0,x1) => x0.attachShadow(x1),
      _856: x0 => x0.computedStyleMap(),
      _857: (x0,x1) => x0.get(x1),
      _863: (x0,x1) => x0.getPropertyValue(x1),
      _864: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _865: x0 => x0.offsetLeft,
      _866: x0 => x0.offsetTop,
      _867: x0 => x0.offsetParent,
      _869: (x0,x1) => { x0.name = x1 },
      _870: x0 => x0.content,
      _871: (x0,x1) => { x0.content = x1 },
      _875: (x0,x1) => { x0.src = x1 },
      _876: x0 => x0.naturalWidth,
      _877: x0 => x0.naturalHeight,
      _881: (x0,x1) => { x0.crossOrigin = x1 },
      _883: (x0,x1) => { x0.decoding = x1 },
      _884: x0 => x0.decode(),
      _889: (x0,x1) => { x0.nonce = x1 },
      _894: (x0,x1) => { x0.width = x1 },
      _896: (x0,x1) => { x0.height = x1 },
      _899: (x0,x1) => x0.getContext(x1),
      _960: x0 => x0.width,
      _961: x0 => x0.height,
      _963: (x0,x1) => x0.fetch(x1),
      _964: x0 => x0.status,
      _965: x0 => x0.headers,
      _966: x0 => x0.body,
      _967: x0 => x0.arrayBuffer(),
      _970: x0 => x0.read(),
      _971: x0 => x0.value,
      _972: x0 => x0.done,
      _979: x0 => x0.name,
      _980: x0 => x0.x,
      _981: x0 => x0.y,
      _984: x0 => x0.top,
      _985: x0 => x0.right,
      _986: x0 => x0.bottom,
      _987: x0 => x0.left,
      _997: x0 => x0.height,
      _998: x0 => x0.width,
      _999: x0 => x0.scale,
      _1000: (x0,x1) => { x0.value = x1 },
      _1003: (x0,x1) => { x0.placeholder = x1 },
      _1005: (x0,x1) => { x0.name = x1 },
      _1006: x0 => x0.selectionDirection,
      _1007: x0 => x0.selectionStart,
      _1008: x0 => x0.selectionEnd,
      _1011: x0 => x0.value,
      _1013: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1014: x0 => x0.readText(),
      _1015: (x0,x1) => x0.writeText(x1),
      _1017: x0 => x0.altKey,
      _1018: x0 => x0.code,
      _1019: x0 => x0.ctrlKey,
      _1020: x0 => x0.key,
      _1021: x0 => x0.keyCode,
      _1022: x0 => x0.location,
      _1023: x0 => x0.metaKey,
      _1024: x0 => x0.repeat,
      _1025: x0 => x0.shiftKey,
      _1026: x0 => x0.isComposing,
      _1028: x0 => x0.state,
      _1029: (x0,x1) => x0.go(x1),
      _1031: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1032: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1033: x0 => x0.pathname,
      _1034: x0 => x0.search,
      _1035: x0 => x0.hash,
      _1039: x0 => x0.state,
      _1042: (x0,x1) => x0.createObjectURL(x1),
      _1044: x0 => new Blob(x0),
      _1046: x0 => new MutationObserver(x0),
      _1047: (x0,x1,x2) => x0.observe(x1,x2),
      _1048: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1048(f,arguments.length,x0,x1) }),
      _1051: x0 => x0.attributeName,
      _1052: x0 => x0.type,
      _1053: x0 => x0.matches,
      _1054: x0 => x0.matches,
      _1058: x0 => x0.relatedTarget,
      _1060: x0 => x0.clientX,
      _1061: x0 => x0.clientY,
      _1062: x0 => x0.offsetX,
      _1063: x0 => x0.offsetY,
      _1066: x0 => x0.button,
      _1067: x0 => x0.buttons,
      _1068: x0 => x0.ctrlKey,
      _1072: x0 => x0.pointerId,
      _1073: x0 => x0.pointerType,
      _1074: x0 => x0.pressure,
      _1075: x0 => x0.tiltX,
      _1076: x0 => x0.tiltY,
      _1077: x0 => x0.getCoalescedEvents(),
      _1080: x0 => x0.deltaX,
      _1081: x0 => x0.deltaY,
      _1082: x0 => x0.wheelDeltaX,
      _1083: x0 => x0.wheelDeltaY,
      _1084: x0 => x0.deltaMode,
      _1091: x0 => x0.changedTouches,
      _1094: x0 => x0.clientX,
      _1095: x0 => x0.clientY,
      _1098: x0 => x0.data,
      _1101: (x0,x1) => { x0.disabled = x1 },
      _1103: (x0,x1) => { x0.type = x1 },
      _1104: (x0,x1) => { x0.max = x1 },
      _1105: (x0,x1) => { x0.min = x1 },
      _1106: x0 => x0.value,
      _1107: (x0,x1) => { x0.value = x1 },
      _1108: x0 => x0.disabled,
      _1109: (x0,x1) => { x0.disabled = x1 },
      _1111: (x0,x1) => { x0.placeholder = x1 },
      _1112: (x0,x1) => { x0.name = x1 },
      _1115: (x0,x1) => { x0.autocomplete = x1 },
      _1116: x0 => x0.selectionDirection,
      _1117: x0 => x0.selectionStart,
      _1119: x0 => x0.selectionEnd,
      _1122: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1123: (x0,x1) => x0.add(x1),
      _1126: (x0,x1) => { x0.noValidate = x1 },
      _1127: (x0,x1) => { x0.method = x1 },
      _1128: (x0,x1) => { x0.action = x1 },
      _1154: x0 => x0.orientation,
      _1155: x0 => x0.width,
      _1156: x0 => x0.height,
      _1157: (x0,x1) => x0.lock(x1),
      _1176: x0 => new ResizeObserver(x0),
      _1179: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1179(f,arguments.length,x0,x1) }),
      _1187: x0 => x0.length,
      _1188: x0 => x0.iterator,
      _1189: x0 => x0.Segmenter,
      _1190: x0 => x0.v8BreakIterator,
      _1191: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1194: x0 => x0.language,
      _1195: x0 => x0.script,
      _1196: x0 => x0.region,
      _1214: x0 => x0.done,
      _1215: x0 => x0.value,
      _1216: x0 => x0.index,
      _1220: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1221: (x0,x1) => x0.adoptText(x1),
      _1222: x0 => x0.first(),
      _1223: x0 => x0.next(),
      _1224: x0 => x0.current(),
      _1238: x0 => x0.hostElement,
      _1239: x0 => x0.viewConstraints,
      _1242: x0 => x0.maxHeight,
      _1243: x0 => x0.maxWidth,
      _1244: x0 => x0.minHeight,
      _1245: x0 => x0.minWidth,
      _1246: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1246(f,arguments.length,x0) }),
      _1247: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1247(f,arguments.length,x0) }),
      _1248: (x0,x1) => ({addView: x0,removeView: x1}),
      _1251: x0 => x0.loader,
      _1252: () => globalThis._flutter,
      _1253: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1254: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1254(f,arguments.length,x0) }),
      _1255: f => finalizeWrapper(f, function() { return dartInstance.exports._1255(f,arguments.length) }),
      _1256: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1259: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1259(f,arguments.length,x0) }),
      _1260: x0 => ({runApp: x0}),
      _1262: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1262(f,arguments.length,x0,x1) }),
      _1263: x0 => x0.length,
      _1264: () => globalThis.window.ImageDecoder,
      _1265: x0 => x0.tracks,
      _1267: x0 => x0.completed,
      _1269: x0 => x0.image,
      _1275: x0 => x0.displayWidth,
      _1276: x0 => x0.displayHeight,
      _1277: x0 => x0.duration,
      _1280: x0 => x0.ready,
      _1281: x0 => x0.selectedTrack,
      _1282: x0 => x0.repetitionCount,
      _1283: x0 => x0.frameCount,
      _1335: x0 => x0.getVideoTracks(),
      _1337: x0 => x0.getAudioTracks(),
      _1338: (x0,x1) => x0.append(x1),
      _1340: x0 => x0.load(),
      _1341: x0 => x0.remove(),
      _1343: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1344: (x0,x1) => x0.appendChild(x1),
      _1345: x0 => x0.requestFullscreen(),
      _1346: x0 => x0.exitFullscreen(),
      _1354: x0 => x0.createRange(),
      _1355: (x0,x1) => x0.selectNode(x1),
      _1356: x0 => x0.getSelection(),
      _1357: x0 => x0.removeAllRanges(),
      _1358: (x0,x1) => x0.addRange(x1),
      _1359: (x0,x1) => x0.createElement(x1),
      _1360: (x0,x1) => x0.append(x1),
      _1361: (x0,x1,x2) => x0.insertRule(x1,x2),
      _1362: (x0,x1) => x0.add(x1),
      _1363: x0 => x0.preventDefault(),
      _1364: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1364(f,arguments.length,x0) }),
      _1365: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1367: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1368: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1369: (x0,x1) => x0.createElement(x1),
      _1374: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1375: () => globalThis.Notification.requestPermission(),
      _1376: x0 => x0.decode(),
      _1377: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1378: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1379: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1379(f,arguments.length,x0) }),
      _1380: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1380(f,arguments.length,x0) }),
      _1381: x0 => x0.send(),
      _1382: () => new XMLHttpRequest(),
      _1383: x0 => globalThis.Wakelock.toggle(x0),
      _1385: (x0,x1) => x0.querySelector(x1),
      _1386: (x0,x1) => x0.item(x1),
      _1388: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1389: x0 => x0.click(),
      _1390: x0 => globalThis.URL.createObjectURL(x0),
      _1391: () => new AudioContext(),
      _1392: (x0,x1) => x0.createMediaElementSource(x1),
      _1393: x0 => x0.createStereoPanner(),
      _1394: (x0,x1) => x0.connect(x1),
      _1395: x0 => x0.play(),
      _1396: x0 => x0.pause(),
      _1398: (x0,x1) => x0.removeItem(x1),
      _1402: x0 => ({audio: x0}),
      _1403: (x0,x1) => x0.getUserMedia(x1),
      _1404: x0 => x0.stop(),
      _1405: x0 => ({video: x0}),
      _1406: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1406(f,arguments.length,x0) }),
      _1407: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1407(f,arguments.length,x0) }),
      _1408: (x0,x1,x2) => x0.getCurrentPosition(x1,x2),
      _1411: x0 => ({type: x0}),
      _1412: (x0,x1) => new Blob(x0,x1),
      _1413: () => new FileReader(),
      _1415: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1416: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1416(f,arguments.length,x0) }),
      _1417: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1418: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1418(f,arguments.length,x0) }),
      _1419: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1419(f,arguments.length,x0) }),
      _1420: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1420(f,arguments.length,x0) }),
      _1421: (x0,x1) => x0.removeChild(x1),
      _1422: x0 => new Blob(x0),
      _1492: Date.now,
      _1494: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1495: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1496: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1497: () => typeof dartUseDateNowForTicks !== "undefined",
      _1498: () => 1000 * performance.now(),
      _1499: () => Date.now(),
      _1500: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1501: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1502: () => new WeakMap(),
      _1503: (map, o) => map.get(o),
      _1504: (map, o, v) => map.set(o, v),
      _1505: x0 => new WeakRef(x0),
      _1506: x0 => x0.deref(),
      _1507: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1507(f,arguments.length,x0) }),
      _1508: x0 => new FinalizationRegistry(x0),
      _1510: (x0,x1,x2) => x0.register(x1,x2),
      _1513: () => globalThis.WeakRef,
      _1514: () => globalThis.FinalizationRegistry,
      _1517: s => JSON.stringify(s),
      _1518: s => printToConsole(s),
      _1519: (o, p, r) => o.replaceAll(p, () => r),
      _1520: (o, p, r) => o.replace(p, () => r),
      _1521: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1522: s => s.toUpperCase(),
      _1523: s => s.trim(),
      _1524: s => s.trimLeft(),
      _1525: s => s.trimRight(),
      _1526: (string, times) => string.repeat(times),
      _1527: Function.prototype.call.bind(String.prototype.indexOf),
      _1528: (s, p, i) => s.lastIndexOf(p, i),
      _1529: (string, token) => string.split(token),
      _1530: Object.is,
      _1531: o => o instanceof Array,
      _1532: (a, i) => a.push(i),
      _1533: (a, i) => a.splice(i, 1)[0],
      _1535: (a, l) => a.length = l,
      _1536: a => a.pop(),
      _1537: (a, i) => a.splice(i, 1),
      _1538: (a, s) => a.join(s),
      _1539: (a, s, e) => a.slice(s, e),
      _1540: (a, s, e) => a.splice(s, e),
      _1541: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1542: a => a.length,
      _1543: (a, l) => a.length = l,
      _1544: (a, i) => a[i],
      _1545: (a, i, v) => a[i] = v,
      _1547: o => {
        if (o instanceof ArrayBuffer) return 0;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 1;
        }
        return 2;
      },
      _1548: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1550: o => o instanceof Uint8Array,
      _1551: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1552: o => o instanceof Int8Array,
      _1553: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1554: o => o instanceof Uint8ClampedArray,
      _1555: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1556: o => o instanceof Uint16Array,
      _1557: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1558: o => o instanceof Int16Array,
      _1559: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1560: o => o instanceof Uint32Array,
      _1561: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1562: o => o instanceof Int32Array,
      _1563: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1565: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1566: o => o instanceof Float32Array,
      _1567: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1568: o => o instanceof Float64Array,
      _1569: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1570: (t, s) => t.set(s),
      _1571: l => new DataView(new ArrayBuffer(l)),
      _1572: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1573: o => o.byteLength,
      _1574: o => o.buffer,
      _1575: o => o.byteOffset,
      _1576: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1577: (b, o) => new DataView(b, o),
      _1578: (b, o, l) => new DataView(b, o, l),
      _1579: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1580: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1581: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1582: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1583: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1584: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1585: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1586: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1587: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1588: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1589: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1590: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1593: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1594: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1595: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1596: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1597: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1598: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1611: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1612: (handle) => clearTimeout(handle),
      _1613: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1614: (handle) => clearInterval(handle),
      _1615: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1616: () => Date.now(),
      _1617: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _1618: (x0,x1) => x0.exec(x1),
      _1619: (x0,x1) => x0.test(x1),
      _1620: x0 => x0.pop(),
      _1622: o => o === undefined,
      _1624: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _1626: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _1627: o => o instanceof RegExp,
      _1628: (l, r) => l === r,
      _1629: o => o,
      _1630: o => o,
      _1631: o => o,
      _1632: b => !!b,
      _1633: o => o.length,
      _1635: (o, i) => o[i],
      _1636: f => f.dartFunction,
      _1637: () => ({}),
      _1638: () => [],
      _1640: () => globalThis,
      _1641: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _1642: (o, p) => p in o,
      _1643: (o, p) => o[p],
      _1644: (o, p, v) => o[p] = v,
      _1645: (o, m, a) => o[m].apply(o, a),
      _1647: o => String(o),
      _1648: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _1649: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1649(f,arguments.length,x0) }),
      _1650: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1650(f,arguments.length,x0,x1) }),
      _1651: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      _1652: o => [o],
      _1653: (o0, o1) => [o0, o1],
      _1654: (o0, o1, o2) => [o0, o1, o2],
      _1655: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _1656: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1657: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1658: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1659: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1660: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1661: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1662: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1663: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1664: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1665: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1666: x0 => new ArrayBuffer(x0),
      _1667: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _1668: x0 => x0.input,
      _1669: x0 => x0.index,
      _1670: x0 => x0.groups,
      _1671: x0 => x0.flags,
      _1672: x0 => x0.multiline,
      _1673: x0 => x0.ignoreCase,
      _1674: x0 => x0.unicode,
      _1675: x0 => x0.dotAll,
      _1676: (x0,x1) => { x0.lastIndex = x1 },
      _1677: (o, p) => p in o,
      _1678: (o, p) => o[p],
      _1679: (o, p, v) => o[p] = v,
      _1680: (o, p) => delete o[p],
      _1688: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1688(f,arguments.length,x0) }),
      _1689: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1689(f,arguments.length,x0) }),
      _1690: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1690(f,arguments.length,x0) }),
      _1691: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1691(f,arguments.length,x0) }),
      _1692: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1692(f,arguments.length,x0) }),
      _1693: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1693(f,arguments.length,x0) }),
      _1694: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1694(f,arguments.length,x0) }),
      _1695: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1695(f,arguments.length,x0) }),
      _1696: x0 => x0.close(),
      _1698: (x0,x1) => x0.createOffer(x1),
      _1702: (x0,x1) => ({type: x0,sdp: x1}),
      _1703: (x0,x1) => x0.setLocalDescription(x1),
      _1704: (x0,x1) => ({type: x0,sdp: x1}),
      _1705: (x0,x1) => x0.setRemoteDescription(x1),
      _1717: (x0,x1,x2) => x0.addTrack(x1,x2),
      _1722: (x0,x1,x2) => x0.addTransceiver(x1,x2),
      _1727: x0 => new RTCPeerConnection(x0),
      _1740: (x0,x1) => ({video: x0,audio: x1}),
      _1752: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1752(f,arguments.length,x0) }),
      _1753: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1753(f,arguments.length,x0) }),
      _1754: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1754(f,arguments.length,x0) }),
      _1769: (x0,x1,x2) => x0.transaction(x1,x2),
      _1770: (x0,x1) => x0.objectStore(x1),
      _1771: (x0,x1) => x0.getAllKeys(x1),
      _1772: (x0,x1) => x0.getAll(x1),
      _1774: (x0,x1) => x0.delete(x1),
      _1775: (x0,x1,x2) => x0.put(x1,x2),
      _1777: x0 => x0.close(),
      _1779: (x0,x1,x2) => x0.open(x1,x2),
      _1780: (x0,x1) => x0.contains(x1),
      _1783: (x0,x1) => x0.createObjectStore(x1),
      _1784: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1784(f,arguments.length,x0) }),
      _1785: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1785(f,arguments.length,x0) }),
      _1794: () => new XMLHttpRequest(),
      _1795: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1799: x0 => x0.send(),
      _1801: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1801(f,arguments.length,x0) }),
      _1802: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1802(f,arguments.length,x0) }),
      _1814: (x0,x1) => new WebSocket(x0,x1),
      _1815: (x0,x1) => x0.send(x1),
      _1816: (x0,x1,x2) => x0.close(x1,x2),
      _1817: (x0,x1) => x0.close(x1),
      _1818: x0 => x0.close(),
      _1820: (x0,x1) => x0.item(x1),
      _1821: (x0,x1) => x0.append(x1),
      _1822: x0 => ({xhrSetup: x0}),
      _1823: x0 => new Hls(x0),
      _1824: () => globalThis.Hls.isSupported(),
      _1826: (x0,x1) => x0.loadSource(x1),
      _1827: (x0,x1) => x0.attachMedia(x1),
      _1828: (x0,x1) => x0.end(x1),
      _1832: (x0,x1) => x0.canPlayType(x1),
      _1833: () => new AbortController(),
      _1834: x0 => x0.abort(),
      _1835: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _1836: (x0,x1) => globalThis.fetch(x0,x1),
      _1837: (x0,x1) => x0.get(x1),
      _1838: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1838(f,arguments.length,x0,x1,x2) }),
      _1839: (x0,x1) => x0.forEach(x1),
      _1840: x0 => x0.getReader(),
      _1841: x0 => x0.cancel(),
      _1842: x0 => x0.read(),
      _1843: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1843(f,arguments.length,x0) }),
      _1844: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1844(f,arguments.length,x0) }),
      _1845: x0 => x0.openCursor(),
      _1846: x0 => x0.continue(),
      _1847: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1847(f,arguments.length,x0) }),
      _1848: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1848(f,arguments.length,x0) }),
      _1852: x0 => x0.random(),
      _1853: (x0,x1) => x0.getRandomValues(x1),
      _1854: () => globalThis.crypto,
      _1855: () => globalThis.Math,
      _1863: Function.prototype.call.bind(Number.prototype.toString),
      _1864: Function.prototype.call.bind(BigInt.prototype.toString),
      _1865: Function.prototype.call.bind(Number.prototype.toString),
      _1866: (d, digits) => d.toFixed(digits),
      _1870: () => globalThis.window,
      _1871: x0 => x0.crypto,
      _1872: x0 => x0.subtle,
      _1875: (x0,x1,x2,x3) => x0.decrypt(x1,x2,x3),
      _1878: (x0,x1,x2) => x0.digest(x1,x2),
      _1881: (x0,x1,x2,x3) => x0.generateKey(x1,x2,x3),
      _1884: (x0,x1,x2) => x0.exportKey(x1,x2),
      _1889: x0 => x0.privateKey,
      _1890: x0 => x0.publicKey,
      _1891: x0 => x0.name,
      _1892: x0 => x0.message,
      _1924: () => globalThis.document,
      _1925: () => globalThis.window,
      _1930: (x0,x1) => { x0.height = x1 },
      _1932: (x0,x1) => { x0.width = x1 },
      _1935: x0 => x0.head,
      _1936: x0 => x0.classList,
      _1940: (x0,x1) => { x0.innerText = x1 },
      _1941: x0 => x0.style,
      _1943: x0 => x0.sheet,
      _1944: x0 => x0.src,
      _1945: (x0,x1) => { x0.src = x1 },
      _1946: x0 => x0.naturalWidth,
      _1947: x0 => x0.naturalHeight,
      _1954: x0 => x0.offsetX,
      _1955: x0 => x0.offsetY,
      _1956: x0 => x0.button,
      _1963: x0 => x0.status,
      _1964: (x0,x1) => { x0.responseType = x1 },
      _1966: x0 => x0.response,
      _2015: (x0,x1) => { x0.responseType = x1 },
      _2016: x0 => x0.response,
      _2075: (x0,x1) => { x0.draggable = x1 },
      _2091: x0 => x0.style,
      _2663: x0 => x0.videoWidth,
      _2664: x0 => x0.videoHeight,
      _2692: x0 => x0.error,
      _2694: (x0,x1) => { x0.src = x1 },
      _2699: (x0,x1) => { x0.crossOrigin = x1 },
      _2702: (x0,x1) => { x0.preload = x1 },
      _2703: x0 => x0.buffered,
      _2706: x0 => x0.currentTime,
      _2707: (x0,x1) => { x0.currentTime = x1 },
      _2708: x0 => x0.duration,
      _2709: x0 => x0.paused,
      _2712: x0 => x0.playbackRate,
      _2713: (x0,x1) => { x0.playbackRate = x1 },
      _2722: (x0,x1) => { x0.loop = x1 },
      _2724: (x0,x1) => { x0.controls = x1 },
      _2725: x0 => x0.volume,
      _2726: (x0,x1) => { x0.volume = x1 },
      _2727: x0 => x0.muted,
      _2728: (x0,x1) => { x0.muted = x1 },
      _2743: x0 => x0.code,
      _2744: x0 => x0.message,
      _2818: x0 => x0.length,
      _3014: (x0,x1) => { x0.accept = x1 },
      _3028: x0 => x0.files,
      _3054: (x0,x1) => { x0.multiple = x1 },
      _3072: (x0,x1) => { x0.type = x1 },
      _3321: x0 => x0.src,
      _3322: (x0,x1) => { x0.src = x1 },
      _3324: (x0,x1) => { x0.type = x1 },
      _3328: (x0,x1) => { x0.async = x1 },
      _3342: (x0,x1) => { x0.charset = x1 },
      _3790: () => globalThis.window,
      _3827: x0 => x0.self,
      _3850: x0 => x0.navigator,
      _4107: x0 => x0.indexedDB,
      _4114: x0 => x0.localStorage,
      _4220: x0 => x0.geolocation,
      _4223: x0 => x0.mediaDevices,
      _4225: x0 => x0.permissions,
      _4239: x0 => x0.userAgent,
      _4240: x0 => x0.vendor,
      _4289: x0 => x0.data,
      _4662: x0 => x0.readyState,
      _4671: x0 => x0.protocol,
      _4675: (x0,x1) => { x0.binaryType = x1 },
      _4678: x0 => x0.code,
      _4679: x0 => x0.reason,
      _4731: x0 => x0.signalingState,
      _4732: x0 => x0.iceGatheringState,
      _4733: x0 => x0.iceConnectionState,
      _4734: x0 => x0.connectionState,
      _4747: (x0,x1) => { x0.onicegatheringstatechange = x1 },
      _4761: x0 => x0.type,
      _4763: x0 => x0.sdp,
      _4771: x0 => x0.candidate,
      _4772: x0 => x0.sdpMid,
      _4773: x0 => x0.sdpMLineIndex,
      _4795: x0 => x0.candidate,
      _4831: x0 => x0.track,
      _5806: x0 => x0.destination,
      _6320: x0 => x0.type,
      _6321: x0 => x0.target,
      _6361: x0 => x0.signal,
      _6373: x0 => x0.length,
      _6421: x0 => x0.firstChild,
      _6432: () => globalThis.document,
      _6490: x0 => x0.documentElement,
      _6513: x0 => x0.head,
      _6843: (x0,x1) => { x0.id = x1 },
      _6867: (x0,x1) => { x0.innerHTML = x1 },
      _6870: x0 => x0.children,
      _8189: x0 => x0.value,
      _8191: x0 => x0.done,
      _8370: x0 => x0.size,
      _8371: x0 => x0.type,
      _8378: x0 => x0.name,
      _8384: x0 => x0.length,
      _8389: x0 => x0.result,
      _8883: x0 => x0.url,
      _8885: x0 => x0.status,
      _8887: x0 => x0.statusText,
      _8888: x0 => x0.headers,
      _8889: x0 => x0.body,
      _9673: x0 => x0.id,
      _9674: x0 => x0.active,
      _9680: x0 => x0.kind,
      _9681: x0 => x0.id,
      _9682: x0 => x0.label,
      _9683: x0 => x0.enabled,
      _9685: x0 => x0.muted,
      _10330: x0 => x0.result,
      _10331: x0 => x0.error,
      _10336: (x0,x1) => { x0.onsuccess = x1 },
      _10338: (x0,x1) => { x0.onerror = x1 },
      _10342: (x0,x1) => { x0.onupgradeneeded = x1 },
      _10360: x0 => x0.version,
      _10361: x0 => x0.objectStoreNames,
      _10428: x0 => x0.key,
      _10431: x0 => x0.value,
      _10991: (x0,x1) => { x0.border = x1 },
      _11269: (x0,x1) => { x0.display = x1 },
      _11433: (x0,x1) => { x0.height = x1 },
      _12123: (x0,x1) => { x0.width = x1 },
      _12491: x0 => x0.name,
      _12492: x0 => x0.message,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      S: new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
