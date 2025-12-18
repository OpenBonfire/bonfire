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
      _1335: x0 => x0.createRange(),
      _1336: (x0,x1) => x0.selectNode(x1),
      _1337: x0 => x0.getSelection(),
      _1338: x0 => x0.removeAllRanges(),
      _1339: (x0,x1) => x0.addRange(x1),
      _1340: (x0,x1) => x0.createElement(x1),
      _1341: (x0,x1) => x0.append(x1),
      _1342: (x0,x1,x2) => x0.insertRule(x1,x2),
      _1343: (x0,x1) => x0.add(x1),
      _1344: x0 => x0.preventDefault(),
      _1345: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1345(f,arguments.length,x0) }),
      _1346: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1348: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1349: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1350: (x0,x1) => x0.createElement(x1),
      _1357: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1359: x0 => x0.decode(),
      _1360: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1361: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1362: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1362(f,arguments.length,x0) }),
      _1363: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1363(f,arguments.length,x0) }),
      _1364: x0 => x0.send(),
      _1365: () => new XMLHttpRequest(),
      _1368: (x0,x1) => x0.querySelector(x1),
      _1369: (x0,x1) => x0.appendChild(x1),
      _1370: (x0,x1) => x0.item(x1),
      _1373: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1374: x0 => x0.click(),
      _1375: x0 => globalThis.URL.createObjectURL(x0),
      _1399: x0 => ({type: x0}),
      _1400: (x0,x1) => new Blob(x0,x1),
      _1401: () => new FileReader(),
      _1403: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1404: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1404(f,arguments.length,x0) }),
      _1405: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1406: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1406(f,arguments.length,x0) }),
      _1407: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1407(f,arguments.length,x0) }),
      _1408: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1408(f,arguments.length,x0) }),
      _1409: (x0,x1) => x0.removeChild(x1),
      _1410: x0 => new Blob(x0),
      _1480: Date.now,
      _1482: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1483: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1484: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1485: () => typeof dartUseDateNowForTicks !== "undefined",
      _1486: () => 1000 * performance.now(),
      _1487: () => Date.now(),
      _1488: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1489: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1490: () => new WeakMap(),
      _1491: (map, o) => map.get(o),
      _1492: (map, o, v) => map.set(o, v),
      _1493: x0 => new WeakRef(x0),
      _1494: x0 => x0.deref(),
      _1501: () => globalThis.WeakRef,
      _1505: s => JSON.stringify(s),
      _1506: s => printToConsole(s),
      _1507: (o, p, r) => o.replaceAll(p, () => r),
      _1508: (o, p, r) => o.replace(p, () => r),
      _1509: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1510: s => s.toUpperCase(),
      _1511: s => s.trim(),
      _1512: s => s.trimLeft(),
      _1513: s => s.trimRight(),
      _1514: (string, times) => string.repeat(times),
      _1515: Function.prototype.call.bind(String.prototype.indexOf),
      _1516: (s, p, i) => s.lastIndexOf(p, i),
      _1517: (string, token) => string.split(token),
      _1518: Object.is,
      _1519: o => o instanceof Array,
      _1520: (a, i) => a.push(i),
      _1521: (a, i) => a.splice(i, 1)[0],
      _1523: (a, l) => a.length = l,
      _1524: a => a.pop(),
      _1525: (a, i) => a.splice(i, 1),
      _1526: (a, s) => a.join(s),
      _1527: (a, s, e) => a.slice(s, e),
      _1528: (a, s, e) => a.splice(s, e),
      _1529: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1530: a => a.length,
      _1532: (a, i) => a[i],
      _1533: (a, i, v) => a[i] = v,
      _1535: o => {
        if (o instanceof ArrayBuffer) return 0;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 1;
        }
        return 2;
      },
      _1536: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1538: o => o instanceof Uint8Array,
      _1539: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1540: o => o instanceof Int8Array,
      _1541: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1542: o => o instanceof Uint8ClampedArray,
      _1543: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1544: o => o instanceof Uint16Array,
      _1545: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1546: o => o instanceof Int16Array,
      _1547: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1548: o => o instanceof Uint32Array,
      _1549: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1550: o => o instanceof Int32Array,
      _1551: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1553: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1554: o => o instanceof Float32Array,
      _1555: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1556: o => o instanceof Float64Array,
      _1557: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1558: (t, s) => t.set(s),
      _1559: l => new DataView(new ArrayBuffer(l)),
      _1560: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1562: o => o.buffer,
      _1563: o => o.byteOffset,
      _1564: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1565: (b, o) => new DataView(b, o),
      _1566: (b, o, l) => new DataView(b, o, l),
      _1567: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1568: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1569: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1570: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1571: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1572: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1573: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1574: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1575: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1576: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1577: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1578: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1581: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1582: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1583: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1584: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1585: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1586: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1587: x0 => x0.abort(),
      _1588: f => finalizeWrapper(f, function() { return dartInstance.exports._1588(f,arguments.length) }),
      _1589: () => new XMLHttpRequest(),
      _1590: (x0,x1,x2) => x0.open(x1,x2),
      _1591: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1592: (x0,x1) => x0.send(x1),
      _1593: x0 => x0.send(),
      _1594: x0 => x0.getAllResponseHeaders(),
      _1607: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1608: (handle) => clearTimeout(handle),
      _1609: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1610: (handle) => clearInterval(handle),
      _1611: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1612: () => Date.now(),
      _1613: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _1614: (x0,x1) => x0.exec(x1),
      _1615: (x0,x1) => x0.test(x1),
      _1616: x0 => x0.pop(),
      _1618: o => o === undefined,
      _1620: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _1622: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _1623: o => o instanceof RegExp,
      _1624: (l, r) => l === r,
      _1625: o => o,
      _1626: o => o,
      _1627: o => o,
      _1628: b => !!b,
      _1629: o => o.length,
      _1631: (o, i) => o[i],
      _1632: f => f.dartFunction,
      _1633: () => ({}),
      _1634: () => [],
      _1636: () => globalThis,
      _1637: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _1638: (o, p) => p in o,
      _1639: (o, p) => o[p],
      _1640: (o, p, v) => o[p] = v,
      _1641: (o, m, a) => o[m].apply(o, a),
      _1643: o => String(o),
      _1644: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _1645: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1645(f,arguments.length,x0) }),
      _1646: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1646(f,arguments.length,x0,x1) }),
      _1647: o => {
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
      _1648: o => [o],
      _1649: (o0, o1) => [o0, o1],
      _1650: (o0, o1, o2) => [o0, o1, o2],
      _1651: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _1652: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1653: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1654: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1655: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1656: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1657: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1658: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1659: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1660: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1661: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1662: x0 => new ArrayBuffer(x0),
      _1663: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _1665: x0 => x0.index,
      _1666: x0 => x0.groups,
      _1667: x0 => x0.flags,
      _1668: x0 => x0.multiline,
      _1669: x0 => x0.ignoreCase,
      _1670: x0 => x0.unicode,
      _1671: x0 => x0.dotAll,
      _1672: (x0,x1) => { x0.lastIndex = x1 },
      _1673: (o, p) => p in o,
      _1674: (o, p) => o[p],
      _1677: (x0,x1,x2) => x0.transaction(x1,x2),
      _1678: (x0,x1) => x0.objectStore(x1),
      _1679: (x0,x1) => x0.getAllKeys(x1),
      _1680: (x0,x1) => x0.getAll(x1),
      _1682: (x0,x1) => x0.delete(x1),
      _1683: (x0,x1,x2) => x0.put(x1,x2),
      _1685: x0 => x0.close(),
      _1687: (x0,x1,x2) => x0.open(x1,x2),
      _1688: (x0,x1) => x0.contains(x1),
      _1691: (x0,x1) => x0.createObjectStore(x1),
      _1692: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1692(f,arguments.length,x0) }),
      _1693: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1693(f,arguments.length,x0) }),
      _1702: () => new XMLHttpRequest(),
      _1703: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1707: x0 => x0.send(),
      _1709: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1709(f,arguments.length,x0) }),
      _1710: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1710(f,arguments.length,x0) }),
      _1721: (x0,x1) => x0.item(x1),
      _1735: () => new AbortController(),
      _1736: x0 => x0.abort(),
      _1737: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _1738: (x0,x1) => globalThis.fetch(x0,x1),
      _1739: (x0,x1) => x0.get(x1),
      _1740: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1740(f,arguments.length,x0,x1,x2) }),
      _1741: (x0,x1) => x0.forEach(x1),
      _1742: x0 => x0.getReader(),
      _1743: x0 => x0.cancel(),
      _1744: x0 => x0.read(),
      _1745: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1745(f,arguments.length,x0) }),
      _1746: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1746(f,arguments.length,x0) }),
      _1747: x0 => x0.openCursor(),
      _1748: x0 => x0.continue(),
      _1749: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1749(f,arguments.length,x0) }),
      _1750: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1750(f,arguments.length,x0) }),
      _1754: x0 => x0.random(),
      _1755: (x0,x1) => x0.getRandomValues(x1),
      _1756: () => globalThis.crypto,
      _1757: () => globalThis.Math,
      _1766: Function.prototype.call.bind(Number.prototype.toString),
      _1767: Function.prototype.call.bind(BigInt.prototype.toString),
      _1768: Function.prototype.call.bind(Number.prototype.toString),
      _1769: (d, digits) => d.toFixed(digits),
      _1773: () => globalThis.window,
      _1774: x0 => x0.crypto,
      _1775: x0 => x0.subtle,
      _1778: (x0,x1,x2,x3) => x0.decrypt(x1,x2,x3),
      _1781: (x0,x1,x2) => x0.digest(x1,x2),
      _1784: (x0,x1,x2,x3) => x0.generateKey(x1,x2,x3),
      _1787: (x0,x1,x2) => x0.exportKey(x1,x2),
      _1792: x0 => x0.privateKey,
      _1793: x0 => x0.publicKey,
      _1794: x0 => x0.name,
      _1795: x0 => x0.message,
      _1818: () => globalThis.origin,
      _1822: (x0,x1) => { x0.responseType = x1 },
      _1826: (x0,x1) => { x0.withCredentials = x1 },
      _1828: (x0,x1) => { x0.onreadystatechange = x1 },
      _1829: x0 => x0.readyState,
      _1830: x0 => x0.response,
      _1832: x0 => x0.status,
      _1833: x0 => x0.statusText,
      _1846: () => globalThis.document,
      _1847: () => globalThis.window,
      _1852: (x0,x1) => { x0.height = x1 },
      _1854: (x0,x1) => { x0.width = x1 },
      _1857: x0 => x0.head,
      _1858: x0 => x0.classList,
      _1862: (x0,x1) => { x0.innerText = x1 },
      _1863: x0 => x0.style,
      _1865: x0 => x0.sheet,
      _1866: x0 => x0.src,
      _1867: (x0,x1) => { x0.src = x1 },
      _1868: x0 => x0.naturalWidth,
      _1869: x0 => x0.naturalHeight,
      _1876: x0 => x0.offsetX,
      _1877: x0 => x0.offsetY,
      _1878: x0 => x0.button,
      _1885: x0 => x0.status,
      _1886: (x0,x1) => { x0.responseType = x1 },
      _1888: x0 => x0.response,
      _1937: (x0,x1) => { x0.responseType = x1 },
      _1938: x0 => x0.response,
      _1997: (x0,x1) => { x0.draggable = x1 },
      _2013: x0 => x0.style,
      _2937: (x0,x1) => { x0.accept = x1 },
      _2951: x0 => x0.files,
      _2977: (x0,x1) => { x0.multiple = x1 },
      _2995: (x0,x1) => { x0.type = x1 },
      _3244: x0 => x0.src,
      _3245: (x0,x1) => { x0.src = x1 },
      _3247: (x0,x1) => { x0.type = x1 },
      _3251: (x0,x1) => { x0.async = x1 },
      _3265: (x0,x1) => { x0.charset = x1 },
      _3714: () => globalThis.window,
      _3753: x0 => x0.self,
      _3776: x0 => x0.navigator,
      _4033: x0 => x0.indexedDB,
      _4146: x0 => x0.geolocation,
      _4149: x0 => x0.mediaDevices,
      _4151: x0 => x0.permissions,
      _4165: x0 => x0.userAgent,
      _4166: x0 => x0.vendor,
      _6272: x0 => x0.type,
      _6273: x0 => x0.target,
      _6313: x0 => x0.signal,
      _6325: x0 => x0.length,
      _6374: x0 => x0.firstChild,
      _6385: () => globalThis.document,
      _6467: x0 => x0.head,
      _6797: (x0,x1) => { x0.id = x1 },
      _6824: x0 => x0.children,
      _8143: x0 => x0.value,
      _8145: x0 => x0.done,
      _8325: x0 => x0.size,
      _8326: x0 => x0.type,
      _8333: x0 => x0.name,
      _8339: x0 => x0.length,
      _8344: x0 => x0.result,
      _8841: x0 => x0.url,
      _8843: x0 => x0.status,
      _8845: x0 => x0.statusText,
      _8846: x0 => x0.headers,
      _8847: x0 => x0.body,
      _10298: x0 => x0.result,
      _10299: x0 => x0.error,
      _10304: (x0,x1) => { x0.onsuccess = x1 },
      _10306: (x0,x1) => { x0.onerror = x1 },
      _10310: (x0,x1) => { x0.onupgradeneeded = x1 },
      _10328: x0 => x0.version,
      _10329: x0 => x0.objectStoreNames,
      _10396: x0 => x0.key,
      _10399: x0 => x0.value,
      _11237: (x0,x1) => { x0.display = x1 },
      _12459: x0 => x0.name,

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
