
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
  async instantiate(additionalImports, {loadDeferredWasm} = {}) {
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

      throw "Unable to print message: " + js;
    }

    // Converts a Dart List to a JS array. Any Dart objects will be converted, but
    // this will be cheap for JSValues.
    function arrayFromDartList(constructor, list) {
      const exports = dartInstance.exports;
      const read = exports.$listRead;
      const length = exports.$listLength(list);
      const array = new constructor(length);
      for (let i = 0; i < length; i++) {
        array[i] = read(list, i);
      }
      return array;
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

      _1: (x0,x1,x2) => x0.set(x1,x2),
      _2: (x0,x1,x2) => x0.set(x1,x2),
      _6: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._6(f,arguments.length,x0) }),
      _7: x0 => new window.FinalizationRegistry(x0),
      _8: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _9: (x0,x1) => x0.unregister(x1),
      _10: (x0,x1,x2) => x0.slice(x1,x2),
      _11: (x0,x1) => x0.decode(x1),
      _12: (x0,x1) => x0.segment(x1),
      _13: () => new TextDecoder(),
      _14: x0 => x0.buffer,
      _15: x0 => x0.wasmMemory,
      _16: () => globalThis.window._flutter_skwasmInstance,
      _17: x0 => x0.rasterStartMilliseconds,
      _18: x0 => x0.rasterEndMilliseconds,
      _19: x0 => x0.imageBitmaps,
      _192: x0 => x0.select(),
      _193: (x0,x1) => x0.append(x1),
      _194: x0 => x0.remove(),
      _197: x0 => x0.unlock(),
      _202: x0 => x0.getReader(),
      _211: x0 => new MutationObserver(x0),
      _222: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _223: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _226: x0 => new ResizeObserver(x0),
      _229: (x0,x1) => new Intl.Segmenter(x0,x1),
      _230: x0 => x0.next(),
      _231: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _308: x0 => x0.close(),
      _309: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _310: x0 => new window.ImageDecoder(x0),
      _311: x0 => x0.close(),
      _312: x0 => ({frameIndex: x0}),
      _313: (x0,x1) => x0.decode(x1),
      _316: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._316(f,arguments.length,x0) }),
      _317: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._317(f,arguments.length,x0) }),
      _318: (x0,x1) => ({addView: x0,removeView: x1}),
      _319: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._319(f,arguments.length,x0) }),
      _320: f => finalizeWrapper(f, function() { return dartInstance.exports._320(f,arguments.length) }),
      _321: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _322: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._322(f,arguments.length,x0) }),
      _323: x0 => ({runApp: x0}),
      _324: x0 => new Uint8Array(x0),
      _326: x0 => x0.preventDefault(),
      _327: x0 => x0.stopPropagation(),
      _328: (x0,x1) => x0.addListener(x1),
      _329: (x0,x1) => x0.removeListener(x1),
      _330: (x0,x1) => x0.prepend(x1),
      _331: x0 => x0.remove(),
      _332: x0 => x0.disconnect(),
      _333: (x0,x1) => x0.addListener(x1),
      _334: (x0,x1) => x0.removeListener(x1),
      _335: x0 => x0.blur(),
      _336: (x0,x1) => x0.append(x1),
      _337: x0 => x0.remove(),
      _338: x0 => x0.stopPropagation(),
      _342: x0 => x0.preventDefault(),
      _343: (x0,x1) => x0.append(x1),
      _344: x0 => x0.remove(),
      _345: x0 => x0.preventDefault(),
      _350: (x0,x1) => x0.removeChild(x1),
      _351: (x0,x1) => x0.appendChild(x1),
      _352: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _353: (x0,x1) => x0.appendChild(x1),
      _354: (x0,x1) => x0.transferFromImageBitmap(x1),
      _355: (x0,x1) => x0.appendChild(x1),
      _356: (x0,x1) => x0.append(x1),
      _357: (x0,x1) => x0.append(x1),
      _358: (x0,x1) => x0.append(x1),
      _359: x0 => x0.remove(),
      _360: x0 => x0.remove(),
      _361: x0 => x0.remove(),
      _362: (x0,x1) => x0.appendChild(x1),
      _363: (x0,x1) => x0.appendChild(x1),
      _364: x0 => x0.remove(),
      _365: (x0,x1) => x0.append(x1),
      _366: (x0,x1) => x0.append(x1),
      _367: x0 => x0.remove(),
      _368: (x0,x1) => x0.append(x1),
      _369: (x0,x1) => x0.append(x1),
      _370: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _371: (x0,x1) => x0.append(x1),
      _372: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _373: x0 => x0.remove(),
      _374: (x0,x1) => x0.append(x1),
      _375: x0 => x0.remove(),
      _376: (x0,x1) => x0.append(x1),
      _377: x0 => x0.remove(),
      _378: x0 => x0.remove(),
      _379: x0 => x0.getBoundingClientRect(),
      _380: x0 => x0.remove(),
      _393: (x0,x1) => x0.append(x1),
      _394: x0 => x0.remove(),
      _395: (x0,x1) => x0.append(x1),
      _396: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _397: x0 => x0.preventDefault(),
      _398: x0 => x0.preventDefault(),
      _399: x0 => x0.preventDefault(),
      _400: x0 => x0.preventDefault(),
      _401: (x0,x1) => x0.observe(x1),
      _402: x0 => x0.disconnect(),
      _403: (x0,x1) => x0.appendChild(x1),
      _404: (x0,x1) => x0.appendChild(x1),
      _405: (x0,x1) => x0.appendChild(x1),
      _406: (x0,x1) => x0.append(x1),
      _407: x0 => x0.remove(),
      _408: (x0,x1) => x0.append(x1),
      _409: (x0,x1) => x0.append(x1),
      _410: (x0,x1) => x0.appendChild(x1),
      _411: (x0,x1) => x0.append(x1),
      _412: x0 => x0.remove(),
      _413: (x0,x1) => x0.append(x1),
      _414: x0 => x0.remove(),
      _418: (x0,x1) => x0.appendChild(x1),
      _419: x0 => x0.remove(),
      _978: () => globalThis.window.flutterConfiguration,
      _979: x0 => x0.assetBase,
      _984: x0 => x0.debugShowSemanticsNodes,
      _985: x0 => x0.hostElement,
      _986: x0 => x0.multiViewEnabled,
      _987: x0 => x0.nonce,
      _989: x0 => x0.fontFallbackBaseUrl,
      _995: x0 => x0.console,
      _996: x0 => x0.devicePixelRatio,
      _997: x0 => x0.document,
      _998: x0 => x0.history,
      _999: x0 => x0.innerHeight,
      _1000: x0 => x0.innerWidth,
      _1001: x0 => x0.location,
      _1002: x0 => x0.navigator,
      _1003: x0 => x0.visualViewport,
      _1004: x0 => x0.performance,
      _1007: (x0,x1) => x0.dispatchEvent(x1),
      _1008: (x0,x1) => x0.matchMedia(x1),
      _1010: (x0,x1) => x0.getComputedStyle(x1),
      _1011: x0 => x0.screen,
      _1012: (x0,x1) => x0.requestAnimationFrame(x1),
      _1013: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1013(f,arguments.length,x0) }),
      _1018: (x0,x1) => x0.warn(x1),
      _1020: (x0,x1) => x0.debug(x1),
      _1021: () => globalThis.window,
      _1022: () => globalThis.Intl,
      _1023: () => globalThis.Symbol,
      _1026: x0 => x0.clipboard,
      _1027: x0 => x0.maxTouchPoints,
      _1028: x0 => x0.vendor,
      _1029: x0 => x0.language,
      _1030: x0 => x0.platform,
      _1031: x0 => x0.userAgent,
      _1032: x0 => x0.languages,
      _1033: x0 => x0.documentElement,
      _1034: (x0,x1) => x0.querySelector(x1),
      _1038: (x0,x1) => x0.createElement(x1),
      _1039: (x0,x1) => x0.execCommand(x1),
      _1042: (x0,x1) => x0.createTextNode(x1),
      _1043: (x0,x1) => x0.createEvent(x1),
      _1047: x0 => x0.head,
      _1048: x0 => x0.body,
      _1049: (x0,x1) => x0.title = x1,
      _1052: x0 => x0.activeElement,
      _1054: x0 => x0.visibilityState,
      _1056: x0 => x0.hasFocus(),
      _1057: () => globalThis.document,
      _1058: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1059: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1062: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1062(f,arguments.length,x0) }),
      _1063: x0 => x0.target,
      _1065: x0 => x0.timeStamp,
      _1066: x0 => x0.type,
      _1068: x0 => x0.preventDefault(),
      _1070: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _1076: x0 => x0.baseURI,
      _1077: x0 => x0.firstChild,
      _1082: x0 => x0.parentElement,
      _1084: x0 => x0.parentNode,
      _1088: (x0,x1) => x0.removeChild(x1),
      _1089: (x0,x1) => x0.removeChild(x1),
      _1090: x0 => x0.isConnected,
      _1091: (x0,x1) => x0.textContent = x1,
      _1095: (x0,x1) => x0.contains(x1),
      _1101: x0 => x0.firstElementChild,
      _1103: x0 => x0.nextElementSibling,
      _1104: x0 => x0.clientHeight,
      _1105: x0 => x0.clientWidth,
      _1106: x0 => x0.offsetHeight,
      _1107: x0 => x0.offsetWidth,
      _1108: x0 => x0.id,
      _1109: (x0,x1) => x0.id = x1,
      _1112: (x0,x1) => x0.spellcheck = x1,
      _1113: x0 => x0.tagName,
      _1114: x0 => x0.style,
      _1115: (x0,x1) => x0.append(x1),
      _1117: (x0,x1) => x0.getAttribute(x1),
      _1118: x0 => x0.getBoundingClientRect(),
      _1121: (x0,x1) => x0.closest(x1),
      _1124: (x0,x1) => x0.querySelectorAll(x1),
      _1126: x0 => x0.remove(),
      _1127: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _1128: (x0,x1) => x0.removeAttribute(x1),
      _1129: (x0,x1) => x0.tabIndex = x1,
      _1132: (x0,x1) => x0.focus(x1),
      _1133: x0 => x0.scrollTop,
      _1134: (x0,x1) => x0.scrollTop = x1,
      _1135: x0 => x0.scrollLeft,
      _1136: (x0,x1) => x0.scrollLeft = x1,
      _1137: x0 => x0.classList,
      _1138: (x0,x1) => x0.className = x1,
      _1144: (x0,x1) => x0.getElementsByClassName(x1),
      _1146: x0 => x0.click(),
      _1147: (x0,x1) => x0.hasAttribute(x1),
      _1150: (x0,x1) => x0.attachShadow(x1),
      _1155: (x0,x1) => x0.getPropertyValue(x1),
      _1157: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _1159: (x0,x1) => x0.removeProperty(x1),
      _1161: x0 => x0.offsetLeft,
      _1162: x0 => x0.offsetTop,
      _1163: x0 => x0.offsetParent,
      _1165: (x0,x1) => x0.name = x1,
      _1166: x0 => x0.content,
      _1167: (x0,x1) => x0.content = x1,
      _1185: (x0,x1) => x0.nonce = x1,
      _1191: x0 => x0.now(),
      _1193: (x0,x1) => x0.width = x1,
      _1195: (x0,x1) => x0.height = x1,
      _1199: (x0,x1) => x0.getContext(x1),
      _1275: (x0,x1) => x0.fetch(x1),
      _1276: x0 => x0.status,
      _1277: x0 => x0.headers,
      _1278: x0 => x0.body,
      _1279: x0 => x0.arrayBuffer(),
      _1282: (x0,x1) => x0.get(x1),
      _1285: x0 => x0.read(),
      _1286: x0 => x0.value,
      _1287: x0 => x0.done,
      _1289: x0 => x0.name,
      _1290: x0 => x0.x,
      _1291: x0 => x0.y,
      _1294: x0 => x0.top,
      _1295: x0 => x0.right,
      _1296: x0 => x0.bottom,
      _1297: x0 => x0.left,
      _1306: x0 => x0.height,
      _1307: x0 => x0.width,
      _1308: (x0,x1) => x0.value = x1,
      _1310: (x0,x1) => x0.placeholder = x1,
      _1311: (x0,x1) => x0.name = x1,
      _1312: x0 => x0.selectionDirection,
      _1313: x0 => x0.selectionStart,
      _1314: x0 => x0.selectionEnd,
      _1317: x0 => x0.value,
      _1319: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1322: x0 => x0.readText(),
      _1323: (x0,x1) => x0.writeText(x1),
      _1324: x0 => x0.altKey,
      _1325: x0 => x0.code,
      _1326: x0 => x0.ctrlKey,
      _1327: x0 => x0.key,
      _1328: x0 => x0.keyCode,
      _1329: x0 => x0.location,
      _1330: x0 => x0.metaKey,
      _1331: x0 => x0.repeat,
      _1332: x0 => x0.shiftKey,
      _1333: x0 => x0.isComposing,
      _1334: (x0,x1) => x0.getModifierState(x1),
      _1336: x0 => x0.state,
      _1337: (x0,x1) => x0.go(x1),
      _1339: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1341: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1342: x0 => x0.pathname,
      _1343: x0 => x0.search,
      _1344: x0 => x0.hash,
      _1348: x0 => x0.state,
      _1356: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1356(f,arguments.length,x0,x1) }),
      _1358: (x0,x1,x2) => x0.observe(x1,x2),
      _1361: x0 => x0.attributeName,
      _1362: x0 => x0.type,
      _1363: x0 => x0.matches,
      _1366: x0 => x0.matches,
      _1368: x0 => x0.relatedTarget,
      _1369: x0 => x0.clientX,
      _1370: x0 => x0.clientY,
      _1371: x0 => x0.offsetX,
      _1372: x0 => x0.offsetY,
      _1375: x0 => x0.button,
      _1376: x0 => x0.buttons,
      _1377: x0 => x0.ctrlKey,
      _1378: (x0,x1) => x0.getModifierState(x1),
      _1381: x0 => x0.pointerId,
      _1382: x0 => x0.pointerType,
      _1383: x0 => x0.pressure,
      _1384: x0 => x0.tiltX,
      _1385: x0 => x0.tiltY,
      _1386: x0 => x0.getCoalescedEvents(),
      _1388: x0 => x0.deltaX,
      _1389: x0 => x0.deltaY,
      _1390: x0 => x0.wheelDeltaX,
      _1391: x0 => x0.wheelDeltaY,
      _1392: x0 => x0.deltaMode,
      _1398: x0 => x0.changedTouches,
      _1400: x0 => x0.clientX,
      _1401: x0 => x0.clientY,
      _1403: x0 => x0.data,
      _1406: (x0,x1) => x0.disabled = x1,
      _1407: (x0,x1) => x0.type = x1,
      _1408: (x0,x1) => x0.max = x1,
      _1409: (x0,x1) => x0.min = x1,
      _1410: (x0,x1) => x0.value = x1,
      _1411: x0 => x0.value,
      _1412: x0 => x0.disabled,
      _1413: (x0,x1) => x0.disabled = x1,
      _1414: (x0,x1) => x0.placeholder = x1,
      _1415: (x0,x1) => x0.name = x1,
      _1416: (x0,x1) => x0.autocomplete = x1,
      _1417: x0 => x0.selectionDirection,
      _1418: x0 => x0.selectionStart,
      _1419: x0 => x0.selectionEnd,
      _1423: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1428: (x0,x1) => x0.add(x1),
      _1432: (x0,x1) => x0.noValidate = x1,
      _1433: (x0,x1) => x0.method = x1,
      _1434: (x0,x1) => x0.action = x1,
      _1459: x0 => x0.orientation,
      _1460: x0 => x0.width,
      _1461: x0 => x0.height,
      _1462: (x0,x1) => x0.lock(x1),
      _1478: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1478(f,arguments.length,x0,x1) }),
      _1489: x0 => x0.length,
      _1491: (x0,x1) => x0.item(x1),
      _1492: x0 => x0.length,
      _1493: (x0,x1) => x0.item(x1),
      _1494: x0 => x0.iterator,
      _1495: x0 => x0.Segmenter,
      _1496: x0 => x0.v8BreakIterator,
      _1499: x0 => x0.done,
      _1500: x0 => x0.value,
      _1501: x0 => x0.index,
      _1505: (x0,x1) => x0.adoptText(x1),
      _1506: x0 => x0.first(),
      _1507: x0 => x0.next(),
      _1508: x0 => x0.current(),
      _1522: x0 => x0.hostElement,
      _1523: x0 => x0.viewConstraints,
      _1525: x0 => x0.maxHeight,
      _1526: x0 => x0.maxWidth,
      _1527: x0 => x0.minHeight,
      _1528: x0 => x0.minWidth,
      _1529: x0 => x0.loader,
      _1530: () => globalThis._flutter,
      _1531: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1532: (x0,x1,x2) => x0.call(x1,x2),
      _1533: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1533(f,arguments.length,x0,x1) }),
      _1534: x0 => new Promise(x0),
      _1537: x0 => x0.length,
      _1540: x0 => x0.tracks,
      _1544: x0 => x0.image,
      _1551: x0 => x0.displayWidth,
      _1552: x0 => x0.displayHeight,
      _1553: x0 => x0.duration,
      _1556: x0 => x0.ready,
      _1557: x0 => x0.selectedTrack,
      _1558: x0 => x0.repetitionCount,
      _1559: x0 => x0.frameCount,
      _1604: x0 => x0.decode(),
      _1605: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1606: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
      _1607: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1607(f,arguments.length,x0) }),
      _1608: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1609: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1609(f,arguments.length,x0) }),
      _1610: x0 => x0.send(),
      _1611: () => new XMLHttpRequest(),
      _1612: (x0,x1) => x0.createElement(x1),
      _1613: x0 => x0.requestFullscreen(),
      _1614: x0 => x0.exitFullscreen(),
      _1615: x0 => x0.createRange(),
      _1616: (x0,x1) => x0.selectNode(x1),
      _1617: x0 => x0.getSelection(),
      _1618: x0 => x0.removeAllRanges(),
      _1619: (x0,x1) => x0.addRange(x1),
      _1620: (x0,x1) => x0.add(x1),
      _1621: (x0,x1) => x0.append(x1),
      _1622: (x0,x1,x2) => x0.insertRule(x1,x2),
      _1623: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1623(f,arguments.length,x0) }),
      _1624: () => globalThis.Notification.requestPermission(),
      _1626: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1627: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1628: (x0,x1) => x0.createElement(x1),
      _1642: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1665: () => new AudioContext(),
      _1666: (x0,x1) => x0.createMediaElementSource(x1),
      _1667: x0 => x0.createStereoPanner(),
      _1668: (x0,x1) => x0.connect(x1),
      _1669: x0 => x0.load(),
      _1670: x0 => x0.remove(),
      _1671: x0 => x0.play(),
      _1672: x0 => x0.pause(),
      _1673: x0 => globalThis.Wakelock.toggle(x0),
      _1675: (x0,x1) => x0.querySelector(x1),
      _1676: (x0,x1) => x0.appendChild(x1),
      _1683: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1687: (x0,x1) => x0.removeItem(x1),
      _1694: x0 => ({audio: x0}),
      _1695: (x0,x1) => x0.getUserMedia(x1),
      _1696: x0 => x0.getAudioTracks(),
      _1697: x0 => x0.stop(),
      _1698: x0 => ({video: x0}),
      _1699: x0 => x0.getVideoTracks(),
      _1700: x0 => x0.stop(),
      _1701: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1701(f,arguments.length,x0) }),
      _1702: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1702(f,arguments.length,x0) }),
      _1703: (x0,x1,x2) => x0.getCurrentPosition(x1,x2),
      _1706: (x0,x1) => x0.querySelector(x1),
      _1707: (x0,x1) => x0.querySelector(x1),
      _1708: (x0,x1) => x0.item(x1),
      _1711: () => new FileReader(),
      _1712: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1713: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1713(f,arguments.length,x0) }),
      _1714: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1715: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1715(f,arguments.length,x0) }),
      _1716: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1716(f,arguments.length,x0) }),
      _1717: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1717(f,arguments.length,x0) }),
      _1718: (x0,x1) => x0.removeChild(x1),
      _1719: x0 => x0.click(),
      _1720: (x0,x1) => x0.removeChild(x1),
      _1801: () => new Array(),
      _1802: x0 => new Array(x0),
      _1804: x0 => x0.length,
      _1806: (x0,x1) => x0[x1],
      _1807: (x0,x1,x2) => x0[x1] = x2,
      _1810: (x0,x1,x2) => new DataView(x0,x1,x2),
      _1812: x0 => new Int8Array(x0),
      _1813: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _1814: x0 => new Uint8Array(x0),
      _1820: x0 => new Uint16Array(x0),
      _1822: x0 => new Int32Array(x0),
      _1824: x0 => new Uint32Array(x0),
      _1826: x0 => new Float32Array(x0),
      _1828: x0 => new Float64Array(x0),
      _1829: (o, t) => typeof o === t,
      _1830: (o, c) => o instanceof c,
      _1834: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1834(f,arguments.length,x0) }),
      _1835: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1835(f,arguments.length,x0) }),
      _1839: (o, a) => o + a,
      _1860: (decoder, codeUnits) => decoder.decode(codeUnits),
      _1861: () => new TextDecoder("utf-8", {fatal: true}),
      _1862: () => new TextDecoder("utf-8", {fatal: false}),
      _1863: x0 => new WeakRef(x0),
      _1864: x0 => x0.deref(),
      _1865: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1865(f,arguments.length,x0) }),
      _1866: x0 => new FinalizationRegistry(x0),
      _1868: (x0,x1,x2) => x0.register(x1,x2),
      _1870: Date.now,
      _1872: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1873: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1874: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1875: () => typeof dartUseDateNowForTicks !== "undefined",
      _1876: () => 1000 * performance.now(),
      _1877: () => Date.now(),
      _1878: () => {
        // On browsers return `globalThis.location.href`
        if (globalThis.location != null) {
          return globalThis.location.href;
        }
        return null;
      },
      _1879: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1880: () => new WeakMap(),
      _1881: (map, o) => map.get(o),
      _1882: (map, o, v) => map.set(o, v),
      _1883: () => globalThis.WeakRef,
      _1887: () => globalThis.FinalizationRegistry,
      _1894: s => JSON.stringify(s),
      _1895: s => printToConsole(s),
      _1896: a => a.join(''),
      _1897: (o, a, b) => o.replace(a, b),
      _1899: (s, t) => s.split(t),
      _1900: s => s.toLowerCase(),
      _1901: s => s.toUpperCase(),
      _1902: s => s.trim(),
      _1903: s => s.trimLeft(),
      _1904: s => s.trimRight(),
      _1906: (s, p, i) => s.indexOf(p, i),
      _1907: (s, p, i) => s.lastIndexOf(p, i),
      _1908: (s) => s.replace(/\$/g, "$$$$"),
      _1909: Object.is,
      _1910: s => s.toUpperCase(),
      _1911: s => s.toLowerCase(),
      _1912: (a, i) => a.push(i),
      _1913: (a, i) => a.splice(i, 1)[0],
      _1915: (a, l) => a.length = l,
      _1916: a => a.pop(),
      _1917: (a, i) => a.splice(i, 1),
      _1919: (a, s) => a.join(s),
      _1920: (a, s, e) => a.slice(s, e),
      _1921: (a, s, e) => a.splice(s, e),
      _1922: (a, b) => a == b ? 0 : (a > b ? 1 : -1),
      _1923: a => a.length,
      _1924: (a, l) => a.length = l,
      _1925: (a, i) => a[i],
      _1926: (a, i, v) => a[i] = v,
      _1928: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1929: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1930: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1931: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1932: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1933: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1934: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1935: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1937: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1938: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1939: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1940: (t, s) => t.set(s),
      _1941: l => new DataView(new ArrayBuffer(l)),
      _1942: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1943: o => o.byteLength,
      _1944: o => o.buffer,
      _1945: o => o.byteOffset,
      _1946: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1947: (b, o) => new DataView(b, o),
      _1948: (b, o, l) => new DataView(b, o, l),
      _1949: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1950: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1951: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1952: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1953: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1954: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1955: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1956: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1957: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1958: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1959: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1960: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1963: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1964: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1965: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1966: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1967: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1968: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1981: (o, t) => o instanceof t,
      _1983: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1983(f,arguments.length,x0) }),
      _1984: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1984(f,arguments.length,x0) }),
      _1985: o => Object.keys(o),
      _1986: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1987: (handle) => clearTimeout(handle),
      _1988: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1989: (handle) => clearInterval(handle),
      _1990: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1991: () => Date.now(),
      _1994: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1994(f,arguments.length,x0) }),
      _1995: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1995(f,arguments.length,x0) }),
      _1996: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1996(f,arguments.length,x0) }),
      _1997: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1997(f,arguments.length,x0) }),
      _1998: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1998(f,arguments.length,x0) }),
      _1999: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1999(f,arguments.length,x0) }),
      _2000: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2000(f,arguments.length,x0) }),
      _2001: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2001(f,arguments.length,x0) }),
      _2004: (x0,x1) => x0.createOffer(x1),
      _2008: (x0,x1) => ({type: x0,sdp: x1}),
      _2009: (x0,x1) => x0.setLocalDescription(x1),
      _2010: (x0,x1) => ({type: x0,sdp: x1}),
      _2011: (x0,x1) => x0.setRemoteDescription(x1),
      _2021: x0 => x0.close(),
      _2023: (x0,x1,x2) => x0.addTrack(x1,x2),
      _2028: (x0,x1,x2) => x0.addTransceiver(x1,x2),
      _2038: x0 => new RTCPeerConnection(x0),
      _2051: (x0,x1) => ({video: x0,audio: x1}),
      _2068: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2068(f,arguments.length,x0) }),
      _2069: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2069(f,arguments.length,x0) }),
      _2070: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2070(f,arguments.length,x0) }),
      _2090: x0 => x0.getAudioTracks(),
      _2091: x0 => x0.getVideoTracks(),
      _2103: (x0,x1) => new WebSocket(x0,x1),
      _2104: (x0,x1) => x0.send(x1),
      _2105: (x0,x1) => x0.send(x1),
      _2106: (x0,x1,x2) => x0.close(x1,x2),
      _2107: (x0,x1) => x0.close(x1),
      _2108: x0 => x0.close(),
      _2110: (x0,x1) => x0.append(x1),
      _2111: (x0,x1) => x0.append(x1),
      _2112: x0 => ({xhrSetup: x0}),
      _2113: x0 => new Hls(x0),
      _2114: () => globalThis.Hls.isSupported(),
      _2116: (x0,x1) => x0.loadSource(x1),
      _2117: (x0,x1) => x0.attachMedia(x1),
      _2118: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _2119: x0 => x0.pause(),
      _2120: (x0,x1) => x0.end(x1),
      _2121: (x0,x1) => x0.end(x1),
      _2122: x0 => x0.load(),
      _2123: x0 => x0.remove(),
      _2124: x0 => x0.pause(),
      _2125: x0 => x0.play(),
      _2126: x0 => x0.load(),
      _2127: x0 => x0.play(),
      _2128: x0 => x0.pause(),
      _2134: x0 => new Blob(x0),
      _2143: (x0,x1) => x0.canPlayType(x1),
      _2144: (x0,x1,x2) => x0.transaction(x1,x2),
      _2145: (x0,x1) => x0.objectStore(x1),
      _2146: (x0,x1) => x0.getAllKeys(x1),
      _2147: (x0,x1) => x0.getAll(x1),
      _2149: (x0,x1) => x0.delete(x1),
      _2150: (x0,x1,x2) => x0.put(x1,x2),
      _2152: x0 => x0.close(),
      _2154: (x0,x1,x2) => x0.open(x1,x2),
      _2159: (x0,x1) => x0.contains(x1),
      _2160: (x0,x1) => x0.createObjectStore(x1),
      _2161: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2161(f,arguments.length,x0) }),
      _2162: (x0,x1) => x0.contains(x1),
      _2163: (x0,x1) => x0.contains(x1),
      _2164: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2164(f,arguments.length,x0) }),
      _2195: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _2196: (x0,x1,x2) => x0.fetch(x1,x2),
      _2197: (x0,x1) => x0.get(x1),
      _2198: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._2198(f,arguments.length,x0,x1,x2) }),
      _2199: (x0,x1) => x0.forEach(x1),
      _2200: x0 => x0.abort(),
      _2201: () => new AbortController(),
      _2202: x0 => x0.getReader(),
      _2203: x0 => x0.read(),
      _2204: x0 => x0.cancel(),
      _2206: x0 => globalThis.URL.createObjectURL(x0),
      _2207: () => new XMLHttpRequest(),
      _2208: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _2209: x0 => x0.send(),
      _2211: () => new FileReader(),
      _2212: (x0,x1) => x0.readAsArrayBuffer(x1),
      _2221: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2221(f,arguments.length,x0) }),
      _2222: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2222(f,arguments.length,x0) }),
      _2234: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2234(f,arguments.length,x0) }),
      _2235: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2235(f,arguments.length,x0) }),
      _2236: x0 => x0.openCursor(),
      _2237: x0 => x0.continue(),
      _2238: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2238(f,arguments.length,x0) }),
      _2239: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2239(f,arguments.length,x0) }),
      _2240: (x0,x1) => x0.appendChild(x1),
      _2241: (x0,x1) => x0.item(x1),
      _2259: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _2260: (x0,x1) => x0.exec(x1),
      _2261: (x0,x1) => x0.test(x1),
      _2262: (x0,x1) => x0.exec(x1),
      _2263: (x0,x1) => x0.exec(x1),
      _2264: x0 => x0.pop(),
      _2266: o => o === undefined,
      _2285: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _2287: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _2288: o => o instanceof RegExp,
      _2289: (l, r) => l === r,
      _2290: o => o,
      _2291: o => o,
      _2292: o => o,
      _2293: b => !!b,
      _2294: o => o.length,
      _2297: (o, i) => o[i],
      _2298: f => f.dartFunction,
      _2299: l => arrayFromDartList(Int8Array, l),
      _2300: l => arrayFromDartList(Uint8Array, l),
      _2301: l => arrayFromDartList(Uint8ClampedArray, l),
      _2302: l => arrayFromDartList(Int16Array, l),
      _2303: l => arrayFromDartList(Uint16Array, l),
      _2304: l => arrayFromDartList(Int32Array, l),
      _2305: l => arrayFromDartList(Uint32Array, l),
      _2306: l => arrayFromDartList(Float32Array, l),
      _2307: l => arrayFromDartList(Float64Array, l),
      _2308: x0 => new ArrayBuffer(x0),
      _2309: (data, length) => {
        const getValue = dartInstance.exports.$byteDataGetUint8;
        const view = new DataView(new ArrayBuffer(length));
        for (let i = 0; i < length; i++) {
          view.setUint8(i, getValue(data, i));
        }
        return view;
      },
      _2310: l => arrayFromDartList(Array, l),
      _2311: () => ({}),
      _2312: () => [],
      _2313: l => new Array(l),
      _2314: () => globalThis,
      _2315: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _2316: (o, p) => p in o,
      _2317: (o, p) => o[p],
      _2318: (o, p, v) => o[p] = v,
      _2319: (o, m, a) => o[m].apply(o, a),
      _2321: o => String(o),
      _2322: (p, s, f) => p.then(s, f),
      _2323: o => {
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
        return 17;
      },
      _2324: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2325: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2326: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI16ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2327: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI16ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2328: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2329: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2330: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2331: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2332: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2333: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2334: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _2336: x0 => x0.input,
      _2337: x0 => x0.index,
      _2338: x0 => x0.groups,
      _2340: (x0,x1) => x0.exec(x1),
      _2342: x0 => x0.flags,
      _2343: x0 => x0.multiline,
      _2344: x0 => x0.ignoreCase,
      _2345: x0 => x0.unicode,
      _2346: x0 => x0.dotAll,
      _2347: (x0,x1) => x0.lastIndex = x1,
      _2348: (o, p) => p in o,
      _2349: (o, p) => o[p],
      _2350: (o, p, v) => o[p] = v,
      _2351: (o, p) => delete o[p],
      _2352: x0 => x0.random(),
      _2353: x0 => x0.random(),
      _2354: (x0,x1) => x0.getRandomValues(x1),
      _2355: () => globalThis.crypto,
      _2357: () => globalThis.Math,
      _2359: Function.prototype.call.bind(Number.prototype.toString),
      _2360: (d, digits) => d.toFixed(digits),
      _2364: () => globalThis.window,
      _2365: x0 => x0.crypto,
      _2366: x0 => x0.subtle,
      _2369: (x0,x1,x2,x3) => x0.decrypt(x1,x2,x3),
      _2372: (x0,x1,x2) => x0.digest(x1,x2),
      _2375: (x0,x1,x2,x3) => x0.generateKey(x1,x2,x3),
      _2378: (x0,x1,x2) => x0.exportKey(x1,x2),
      _2384: x0 => x0.privateKey,
      _2385: x0 => x0.publicKey,
      _2386: x0 => x0.name,
      _2387: x0 => x0.message,
      _2409: () => globalThis.document,
      _2410: () => globalThis.window,
      _2415: (x0,x1) => x0.height = x1,
      _2417: (x0,x1) => x0.width = x1,
      _2421: x0 => x0.head,
      _2424: x0 => x0.classList,
      _2429: (x0,x1) => x0.innerText = x1,
      _2430: x0 => x0.style,
      _2432: x0 => x0.sheet,
      _2433: x0 => x0.src,
      _2434: (x0,x1) => x0.src = x1,
      _2435: x0 => x0.naturalWidth,
      _2436: x0 => x0.naturalHeight,
      _2444: x0 => x0.offsetX,
      _2445: x0 => x0.offsetY,
      _2446: x0 => x0.button,
      _2461: x0 => x0.status,
      _2462: (x0,x1) => x0.responseType = x1,
      _2464: x0 => x0.response,
      _2522: (x0,x1) => x0.responseType = x1,
      _2523: x0 => x0.response,
      _2587: (x0,x1) => x0.draggable = x1,
      _2603: x0 => x0.style,
      _3176: x0 => x0.videoWidth,
      _3177: x0 => x0.videoHeight,
      _3210: x0 => x0.error,
      _3212: (x0,x1) => x0.src = x1,
      _3217: (x0,x1) => x0.crossOrigin = x1,
      _3220: (x0,x1) => x0.preload = x1,
      _3221: x0 => x0.buffered,
      _3224: x0 => x0.currentTime,
      _3225: (x0,x1) => x0.currentTime = x1,
      _3226: x0 => x0.duration,
      _3227: x0 => x0.paused,
      _3230: x0 => x0.playbackRate,
      _3231: (x0,x1) => x0.playbackRate = x1,
      _3240: (x0,x1) => x0.loop = x1,
      _3242: (x0,x1) => x0.controls = x1,
      _3243: x0 => x0.volume,
      _3244: (x0,x1) => x0.volume = x1,
      _3245: x0 => x0.muted,
      _3246: (x0,x1) => x0.muted = x1,
      _3261: x0 => x0.code,
      _3262: x0 => x0.message,
      _3338: x0 => x0.length,
      _3535: (x0,x1) => x0.accept = x1,
      _3549: x0 => x0.files,
      _3575: (x0,x1) => x0.multiple = x1,
      _3593: (x0,x1) => x0.type = x1,
      _3847: x0 => x0.src,
      _3848: (x0,x1) => x0.src = x1,
      _3850: (x0,x1) => x0.type = x1,
      _3854: (x0,x1) => x0.async = x1,
      _3868: (x0,x1) => x0.charset = x1,
      _4335: () => globalThis.window,
      _4376: x0 => x0.self,
      _4399: x0 => x0.navigator,
      _4403: x0 => x0.screen,
      _4404: x0 => x0.visualViewport,
      _4656: x0 => x0.indexedDB,
      _4663: x0 => x0.localStorage,
      _4771: x0 => x0.geolocation,
      _4774: x0 => x0.mediaDevices,
      _4776: x0 => x0.permissions,
      _4790: x0 => x0.userAgent,
      _4791: x0 => x0.vendor,
      _4841: x0 => x0.data,
      _5231: x0 => x0.readyState,
      _5240: x0 => x0.protocol,
      _5244: (x0,x1) => x0.binaryType = x1,
      _5247: x0 => x0.code,
      _5248: x0 => x0.reason,
      _5309: x0 => x0.signalingState,
      _5310: x0 => x0.iceGatheringState,
      _5311: x0 => x0.iceConnectionState,
      _5312: x0 => x0.connectionState,
      _5325: (x0,x1) => x0.onicegatheringstatechange = x1,
      _5340: x0 => x0.type,
      _5342: x0 => x0.sdp,
      _5350: x0 => x0.candidate,
      _5351: x0 => x0.sdpMid,
      _5352: x0 => x0.sdpMLineIndex,
      _5374: x0 => x0.candidate,
      _5414: x0 => x0.track,
      _6457: x0 => x0.destination,
      _6983: x0 => x0.type,
      _6984: x0 => x0.target,
      _7026: x0 => x0.signal,
      _7039: x0 => x0.length,
      _7094: x0 => x0.firstChild,
      _7105: () => globalThis.document,
      _7177: x0 => x0.documentElement,
      _7200: x0 => x0.head,
      _7549: (x0,x1) => x0.id = x1,
      _7573: (x0,x1) => x0.innerHTML = x1,
      _7576: x0 => x0.children,
      _8930: x0 => x0.value,
      _8932: x0 => x0.done,
      _9118: x0 => x0.size,
      _9126: x0 => x0.name,
      _9133: x0 => x0.length,
      _9144: x0 => x0.result,
      _9651: x0 => x0.url,
      _9653: x0 => x0.status,
      _9655: x0 => x0.statusText,
      _9656: x0 => x0.headers,
      _9657: x0 => x0.body,
      _9964: x0 => x0.height,
      _9992: x0 => x0.height,
      _10461: x0 => x0.id,
      _10462: x0 => x0.active,
      _10472: x0 => x0.kind,
      _10473: x0 => x0.id,
      _10474: x0 => x0.label,
      _10475: x0 => x0.enabled,
      _10477: x0 => x0.muted,
      _11127: x0 => x0.result,
      _11128: x0 => x0.error,
      _11133: (x0,x1) => x0.onsuccess = x1,
      _11135: (x0,x1) => x0.onerror = x1,
      _11139: (x0,x1) => x0.onupgradeneeded = x1,
      _11160: x0 => x0.version,
      _11161: x0 => x0.objectStoreNames,
      _11233: x0 => x0.key,
      _11236: x0 => x0.value,
      _11807: (x0,x1) => x0.border = x1,
      _12085: (x0,x1) => x0.display = x1,
      _12249: (x0,x1) => x0.height = x1,
      _12939: (x0,x1) => x0.width = x1,
      _13317: x0 => x0.message,
      _14073: () => globalThis.window.flutterCanvasKit,
      _14074: () => globalThis.window._flutter_skwasmInstance,

    };

    const baseImports = {
      dart2wasm: dart2wasm,


      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
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
    };

    const deferredLibraryHelper = {
      "loadModule": async (moduleName) => {
        if (!loadDeferredWasm) {
          throw "No implementation of loadDeferredWasm provided.";
        }
        const source = await Promise.resolve(loadDeferredWasm(moduleName));
        const module = await ((source instanceof Response)
            ? WebAssembly.compileStreaming(source, this.builtins)
            : WebAssembly.compile(source, this.builtins));
        return await WebAssembly.instantiate(module, {
          ...baseImports,
          ...additionalImports,
          "wasm:js-string": jsStringPolyfill,
          "module0": dartInstance.exports,
        });
      },
    };

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      "deferredLibraryHelper": deferredLibraryHelper,
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

