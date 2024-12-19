## 4.1.2
__15.6.2024__
- Bumped firebridge to `6.2.9`

## 4.1.1
__15.6.2024__
- Bumped firebridge to `6.2.8`

## 4.1.0
__15.11.2023__
- Added a helper to reply to a message.
- Fixed an issue with paginating back to a page that had already been seen.

## 4.0.0
__20.10.2023__
- Fixed an issue with link formatting.

## 4.0.0-dev.1
__17.09.2023__
- Bump nyxx to `6.0.0`. See the changelog at https://pub.dev/packages/nyxx for more information.
- Removed helpers now in the nyxx package.
- Added pagination support.

## 3.2.0

- Bump nyxx to `4.2.0`
- Correctly export `acronym` property on guild

## 3.1.0
__15.11.2022__

- Bump nyxx to `4.2.0`
- Add an `acronym` property on guild

## 3.0.0
__19.12.2021__

- Create `lib/nyxx_extensions.dart` which exports all sub libraries
- `filterEmojiDefinitions` from `emoji` library now returns `Stream<EmojiDefinition>`
- Export library for each file
- Use minified version of emojis endpoint. Fixes #1
- Add compatibility with nyxx 3.0.0-dev.x****

Other changes are initial implementation of unit and integration tests to assure correct behavior of internal framework
processes. Also added `Makefile` with common commands that are run during development.

## 3.0.0-dev.2
__06.12.2021__

- Add compatibility with nyxx 3.0.0-dev.x

## 3.0.0-dev.1
__02.12.2021__

- Use minified version of emojis endpoint. Fixes #1

## 3.0.0-dev.0
__24.11.2021__

- Create `lib/nyxx_extensions.dart` which exports all sub libraries
- `filterEmojiDefinitions` from `emoji` library now returns `Stream<EmojiDefinition>`
- Export library for each file

Other changes are initial implementation of unit and integration tests to assure correct behavior of internal framework
processes. Also added `Makefile` with common commands that are run during development.

## 2.0.0
_03.10.2021_

> Bumped version to 2.0 for compatibility with nyxx

- Added compatibility for nyxx 2.0.0-rc2
- Implemented mutual guilds extension method (9a8bb35)

## 2.0.0-rc.3
_25.04.2021_

> **Release Candidate 2 for stable version. Requires dart sdk 2.12**

 - Added compatibility for nyxx 2.0.0-rc2
 - Implemented mutual guilds extension method (9a8bb35)

## 1.0.0
_24.08.2020_

> **Stable release - breaks with previous versions - this version required Dart 2.9 stable and non-nullable experiment to be enabled to function**

> **`1.0.0` drops support for browser. Nyxx will now run only on VM**

 - New emoji module for fetching available emoji info 
 - Pagination module for created paginated messages
 - Scheduler module for invoking repeatable actions
 - Additional general utils
 - Message resolver module for resolving raw message content into human readable form
 - Attachment extensions for vm
