import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

const String _webSocketGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

Future<WebSocketChannel> createWebSocket(Uri url) async {
  Random random = Random();
  // Generate 16 random bytes.
  Uint8List nonceData = Uint8List(16);
  for (int i = 0; i < 16; i++) {
    nonceData[i] = random.nextInt(256);
  }
  String nonce = base64Encode(nonceData);

  final callerStackTrace = StackTrace.current;

  HttpClient client = HttpClient();

  final ttt = await client
      .getUrl(Uri.parse("https://remote-auth-gateway.discord.gg/?v=2"))
      .then((HttpClientRequest request) {
    request.headers
      ..set("Connection", "Upgrade", preserveHeaderCase: true)
      ..set("Upgrade", "websocket", preserveHeaderCase: true)
      ..set("Sec-WebSocket-Key", nonce, preserveHeaderCase: true)
      ..set("Cache-Control", "no-cache", preserveHeaderCase: true)
      ..set("Sec-WebSocket-Version", "13", preserveHeaderCase: true)
      ..set("Origin", 'https://discord.com', preserveHeaderCase: true)
      ..set("User-Agent",
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          preserveHeaderCase: true)
      ..set("Referer", 'https://discord.com/login', preserveHeaderCase: true);

    // Optionally write to the request object...
    // Then call close.
    return request.close();
  }).then((HttpClientResponse response) {
    Future<WebSocket> error(String message) {
      // Flush data.
      response.detachSocket().then((socket) {
        socket.destroy();
      });
      return Future<WebSocket>.error(
          WebSocketException(message), callerStackTrace);
    }

    var connectionHeader = response.headers[HttpHeaders.connectionHeader];
    if (response.statusCode != HttpStatus.switchingProtocols ||
        connectionHeader == null ||
        !connectionHeader.any((value) => value.toLowerCase() == "upgrade") ||
        response.headers.value(HttpHeaders.upgradeHeader)!.toLowerCase() !=
            "websocket") {
      return error("Connection was not upgraded to websocket");
    }
    String? accept = response.headers.value("Sec-WebSocket-Accept");
    if (accept == null) {
      return error("Response did not contain a 'Sec-WebSocket-Accept' header");
    }
    _SHA1 sha1 = _SHA1();
    sha1.add("$nonce$_webSocketGUID".codeUnits);
    List<int> expectedAccept = sha1.close();
    List<int> receivedAccept = base64Decode(accept);
    if (expectedAccept.length != receivedAccept.length) {
      return error(
          "Response header 'Sec-WebSocket-Accept' is the wrong length");
    }
    for (int i = 0; i < expectedAccept.length; i++) {
      if (expectedAccept[i] != receivedAccept[i]) {
        return error("Bad response 'Sec-WebSocket-Accept' header");
      }
    }
    // var protocol = response.headers.value('Sec-WebSocket-Protocol');

    return response.detachSocket().then<WebSocket>(
        (socket) => WebSocket.fromUpgradedSocket(socket, serverSide: false));
  });

  print("ttt ${ttt}");

  final WebSocket tt = ttt as WebSocket;

  WebSocketChannel channel = IOWebSocketChannel(tt);

  print("Print ${tt} ${channel}");

  return channel;

  // try {
  //   await channel.ready;

  //   print("Ready");

  //   channel.stream.listen((data) {
  //     final map = jsonDecode(data) as Map<String, dynamic>;

  //     print("${map}");
  //   }, onError: (error) {
  //     print(error);
  //   }, onDone: () {
  //     print("Connection closed ${channel.closeCode}, ${channel.closeReason}");
  //   });
  // } catch (e) {
  //   print(e.toString());
  // }
}

// Constants.
const _MASK_8 = 0xff;
const _MASK_32 = 0xffffffff;
const _BITS_PER_BYTE = 8;
const _BYTES_PER_WORD = 4;

// Base class encapsulating common behavior for cryptographic hash
// functions.
abstract class _HashBase {
  // Hasher state.
  final int _chunkSizeInWords;
  final bool _bigEndianWords;
  int _lengthInBytes = 0;
  List<int> _pendingData;
  final Uint32List _currentChunk;
  final Uint32List _h;
  bool _digestCalled = false;

  _HashBase(this._chunkSizeInWords, int digestSizeInWords, this._bigEndianWords)
      : _pendingData = [],
        _currentChunk = Uint32List(_chunkSizeInWords),
        _h = Uint32List(digestSizeInWords);

  // Update the hasher with more data.
  void add(List<int> data) {
    if (_digestCalled) {
      throw StateError('Hash update method called after digest was retrieved');
    }
    _lengthInBytes += data.length;
    _pendingData.addAll(data);
    _iterate();
  }

  // Finish the hash computation and return the digest string.
  List<int> close() {
    if (_digestCalled) {
      return _resultAsBytes();
    }
    _digestCalled = true;
    _finalizeData();
    _iterate();
    assert(_pendingData.isEmpty);
    return _resultAsBytes();
  }

  // Returns the block size of the hash in bytes.
  int get blockSize {
    return _chunkSizeInWords * _BYTES_PER_WORD;
  }

  // One round of the hash computation.
  _updateHash(Uint32List m);

  // Helper methods.
  int _add32(int x, int y) => (x + y) & _MASK_32;
  int _roundUp(int val, int n) => (val + n - 1) & -n;

  // Rotate left limiting to unsigned 32-bit values.
  int _rotl32(int val, int shift) {
    var mod_shift = shift & 31;
    return ((val << mod_shift) & _MASK_32) |
        ((val & _MASK_32) >> (32 - mod_shift));
  }

  // Compute the final result as a list of bytes from the hash words.
  List<int> _resultAsBytes() {
    var result = <int>[];
    for (var i = 0; i < _h.length; i++) {
      result.addAll(_wordToBytes(_h[i]));
    }
    return result;
  }

  // Converts a list of bytes to a chunk of 32-bit words.
  void _bytesToChunk(List<int> data, int dataIndex) {
    assert((data.length - dataIndex) >= (_chunkSizeInWords * _BYTES_PER_WORD));

    for (var wordIndex = 0; wordIndex < _chunkSizeInWords; wordIndex++) {
      var w3 = _bigEndianWords ? data[dataIndex] : data[dataIndex + 3];
      var w2 = _bigEndianWords ? data[dataIndex + 1] : data[dataIndex + 2];
      var w1 = _bigEndianWords ? data[dataIndex + 2] : data[dataIndex + 1];
      var w0 = _bigEndianWords ? data[dataIndex + 3] : data[dataIndex];
      dataIndex += 4;
      var word = (w3 & 0xff) << 24;
      word |= (w2 & _MASK_8) << 16;
      word |= (w1 & _MASK_8) << 8;
      word |= (w0 & _MASK_8);
      _currentChunk[wordIndex] = word;
    }
  }

  // Convert a 32-bit word to four bytes.
  List<int> _wordToBytes(int word) {
    List<int> bytes = List.filled(_BYTES_PER_WORD, 0);
    bytes[0] = (word >> (_bigEndianWords ? 24 : 0)) & _MASK_8;
    bytes[1] = (word >> (_bigEndianWords ? 16 : 8)) & _MASK_8;
    bytes[2] = (word >> (_bigEndianWords ? 8 : 16)) & _MASK_8;
    bytes[3] = (word >> (_bigEndianWords ? 0 : 24)) & _MASK_8;
    return bytes;
  }

  // Iterate through data updating the hash computation for each
  // chunk.
  void _iterate() {
    var len = _pendingData.length;
    var chunkSizeInBytes = _chunkSizeInWords * _BYTES_PER_WORD;
    if (len >= chunkSizeInBytes) {
      var index = 0;
      for (; (len - index) >= chunkSizeInBytes; index += chunkSizeInBytes) {
        _bytesToChunk(_pendingData, index);
        _updateHash(_currentChunk);
      }
      _pendingData = _pendingData.sublist(index, len);
    }
  }

  // Finalize the data. Add a 1 bit to the end of the message. Expand with
  // 0 bits and add the length of the message.
  void _finalizeData() {
    _pendingData.add(0x80);
    var contentsLength = _lengthInBytes + 9;
    var chunkSizeInBytes = _chunkSizeInWords * _BYTES_PER_WORD;
    var finalizedLength = _roundUp(contentsLength, chunkSizeInBytes);
    var zeroPadding = finalizedLength - contentsLength;
    for (var i = 0; i < zeroPadding; i++) {
      _pendingData.add(0);
    }
    var lengthInBits = _lengthInBytes * _BITS_PER_BYTE;
    assert(lengthInBits < pow(2, 32));
    if (_bigEndianWords) {
      _pendingData.addAll(_wordToBytes(0));
      _pendingData.addAll(_wordToBytes(lengthInBits & _MASK_32));
    } else {
      _pendingData.addAll(_wordToBytes(lengthInBits & _MASK_32));
      _pendingData.addAll(_wordToBytes(0));
    }
  }
}

// The SHA1 hasher is used to compute an SHA1 message digest.
class _SHA1 extends _HashBase {
  final List<int> _w;

  // Construct a SHA1 hasher object.
  _SHA1()
      : _w = List<int>.filled(80, 0),
        super(16, 5, true) {
    _h[0] = 0x67452301;
    _h[1] = 0xEFCDAB89;
    _h[2] = 0x98BADCFE;
    _h[3] = 0x10325476;
    _h[4] = 0xC3D2E1F0;
  }

  // Compute one iteration of the SHA1 algorithm with a chunk of
  // 16 32-bit pieces.
  void _updateHash(Uint32List m) {
    assert(m.length == 16);

    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];
    var e = _h[4];

    for (var i = 0; i < 80; i++) {
      if (i < 16) {
        _w[i] = m[i];
      } else {
        var n = _w[i - 3] ^ _w[i - 8] ^ _w[i - 14] ^ _w[i - 16];
        _w[i] = _rotl32(n, 1);
      }
      var t = _add32(_add32(_rotl32(a, 5), e), _w[i]);
      if (i < 20) {
        t = _add32(_add32(t, (b & c) | (~b & d)), 0x5A827999);
      } else if (i < 40) {
        t = _add32(_add32(t, (b ^ c ^ d)), 0x6ED9EBA1);
      } else if (i < 60) {
        t = _add32(_add32(t, (b & c) | (b & d) | (c & d)), 0x8F1BBCDC);
      } else {
        t = _add32(_add32(t, b ^ c ^ d), 0xCA62C1D6);
      }

      e = d;
      d = c;
      c = _rotl32(b, 30);
      b = a;
      a = t & _MASK_32;
    }

    _h[0] = _add32(a, _h[0]);
    _h[1] = _add32(b, _h[1]);
    _h[2] = _add32(c, _h[2]);
    _h[3] = _add32(d, _h[3]);
    _h[4] = _add32(e, _h[4]);
  }
}
