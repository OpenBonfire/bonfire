import 'dart:convert';

class Headers {
  static var superProps = {
    'os': 'Windows',
    'browser': 'Chrome',
    'device': '',
    'browser_user_agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36',
    'browser_version': '96.0.4664.110',
    'os_version': '10',
    'referrer': '',
    'referring_domain': '',
    'referrer_current': '',
    'referring_domain_current': '',
    'release_channel': 'stable',
    'system_locale': 'en-US',
    'client_build_number': 844,
    'client_event_source': null,
    'design_id': 0,
  };

  static Map<String, String> getHeaders() => {
        "X-Discord-Timezone": "America/New_York",
        "Sec-Ch-Ua-Platform": '"Windows"',
        'Accept-Language': 'en-US',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Origin': 'https://discord.com',
        'Pragma': 'no-cache',
        'Referer': 'https://discord.com/channels/@me',
        'Sec-CH-UA':
            '"Google Chrome";v="96", "Chromium";v=96", ";Not-A.Brand";v="24"',
        'Sec-CH-UA-Mobile': '?0',
        'Sec-CH-UA-Platform': '"Windows"',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36',
        'X-Discord-Locale': 'en-US',
        'X-Debug-Options': 'bugReporterEnabled',
        "X-Super-Properties": base64Encode(utf8.encode(jsonEncode(superProps))),
        "Content-Type": "application/json"
      };
}
