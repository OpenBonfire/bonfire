*What if the Discord client was blazingly fast?*

You can find us on Discord: https://discord.gg/QafRarw25u

# Usage
The fastest way to give it a go is at https://app.openbonfire.dev/! Note that at the time it will most likely require a token to login! This is because everything in the web version is proxied, so Discord requires captcha (which isn't implemented in Bonfire quite yet).

We now offer nightly builds! Please check out the [github actions](https://github.com/OpenBonfire/bonfire/actions) for the latest builds. _You must be logged into to GitHub to view these builds_.

**NOTE**: Bonfire is in it's very early stages of development. It is absolutely NOT ready for regular usage.

# Bonfire
![bonfire graphic frame](https://github.com/user-attachments/assets/75d9de58-3bd3-4605-a409-798fd4ba3643)


## About
A modern alternative to the Discord client. Use Discord without ever having to touch the mobile Discord client.

## Platform Support
| Platform   | Support Level | Notes                                                                 |
|------------|---------------|-----------------------------------------------------------------------|
| Android    | 🟩 Supported  | Fully functional                                                     |
| iOS        | 🟩 Supported  | Functional but needs testing                                         |
| Windows    | 🟩 Supported  | Fully functional                                                     |
| MacOS      | 🟩 Supported     | Hypothetically close to working but needs fixes                      |
| Linux      | 🟩 Supported  | Fully functional                                                     |
| WearOS     | 🟨 Partial    | Works but requires manual token input                                |
| Web        | 🟩 Supported  | Functional but requires token login                                  |


## General Goals / Ethic
To start, lets outline a few things.
- This is not a seperate platform. You login with Discord, you are using all of Discord's features, but through the interface we've made instead of through Discord's.

- **This is against TOS**. Don't do use this unless you have some risk tolerance. *I have never gotten banned in the development of Bonfire, but that isn't to say it can't happen*.

- Bonfire is for all platforms. The goal motivation for the project is mobile, as that's where current modding is far worse, however it works great on Web, Windows and Linux as well!

- **Extensions are planned**. We plan on using (wasm_run)[https://github.com/juancastillo0/wasm_run] to allow for users to extend the functionality of Bonfire to their liking, and we also plan on hosting a marketplace where users can publish their plugins / download the plugins other people make.

# Developing
## General Info
There's a few projects that OpenBonfire uses and maintains, which can be found in our org. Let's just talk about the big ones.
- [firebridge](https://github.com/OpenBonfire/bonfire/tree/main/firebridge): A fork of nyxx (a bot API for Dart) that allows the usage of user tokens. This is where most of the networking logic happens.
- [fireview](https://github.com/OpenBonfire/fireview): A cross-platform webview API that combines multiple webview frameworks. We recently switched away from this because of conflicts on Windows and Linux. Ideally this is what we use in the future.

## Progress

| Feature Category       | Sub-feature                | Status      | Notes                                                                 |
|------------------------|----------------------------|-------------|-----------------------------------------------------------------------|
| **Login**              | WebView-based login        | 🟩 Complete |                                                                       |
|                        | Web Login                  | 🟨 Partial  | Requires manual token input                                          |
|                        | WearOS login support       | 🟥 Missing  | Requires compiling with hard-coded token                              |
| **Messaging**          | Sending Messages           | 🟩 Complete |                                                                       |
|                        | Cache Messages             | 🟩 Complete |                                                                       |
|                        | Message View               | 🟨 Partial  | Missing bidirectional requests                                       |
|                        | Context Actions            | 🟨 Partial  | Edit, delete, etc. partially implemented                             |
|                        | Event Actions              | 🟨 Partial  | Edit, delete, etc. partially implemented                             |
|                        | Embeds                     | 🟩 Complete |                                                                       |
|                        | → YouTube embeds           | 🟩 Complete |                                                                       |
|                        | → Tenor videos             | 🟩 Complete |                                                                       |
|                        | → Attachments              | 🟩 Complete |                                                                       |
|                        | →→ Image Attachments       | 🟩 Complete |                                                                       |
|                        | →→ Video Attachments       | 🟩 Complete |                                                                       |
|                        | →→ Audio Attachments       | 🟩 Complete | With mobile playback support                                         |
|                        | Notifications              | 🟩 Complete |                                                                       |
|                        | Unreads                    | 🟨 Partial  | Somewhat buggy                                                       |
|                        | Threads                    | 🟥 Missing  |                                                                       |
|                        | Member List                | 🟨 Partial  |                                                                       |
|                        | → Base View                | 🟩 Complete |                                                                       |
|                        | → Networking               | 🟩 Complete | Handled in firebridge                                                |
|                        | → Member Search            | 🟥 Missing  |                                                                       |
| **Friends**            |                            | 🟨 Partial  |                                                                       |
| **Guilds**             | Guild List                 | 🟩 Complete |                                                                       |
|                        | Guild Networking           | 🟩 Complete |                                                                       |
|                        | Guild Organization         | 🟩 Complete |                                                                       |
|                        | → Guild Order              | 🟩 Complete |                                                                       |
|                        | → Guild Names              | 🟩 Complete |                                                                       |
|                        | → Guild Folders            | 🟩 Complete |                                                                       |
| **Voice/Video**        | Voice Chat                 | 🟥 Missing  | Planned but difficult to implement                                   |
|                        | Camera Chat                | 🟥 Missing  | Planned but difficult to implement                                   |
|                        | Screen Sharing             | 🟥 Missing  | Planned but difficult to implement                                   |

*Not exhaustive - there's a lot of stuff to do*
## Building
- Clone Bonfire
- Run `flutter pub run`
- Run `dart run build_runner watch -d` in a seperate terminal
- You are on your way!

## Build issues (mostly linux)
You may encounter issues on Linux (usually with packaging)
1. **libmpv cannot be found**: Download `libmpv` / `libmpv-devel` (package name varies per distro). If you get an issue in adjacent to `libmpv cannot be found` and it is installed (particuarly on Fedora), run `sudo ln -s /usr/lib64/libmpv.so.2 /usr/lib64/libmpv.so.1`. This issue also appears when running the release varient from GitHub. I will eventually bundle the depend or apply this fix in the library itself. This issue is tracked at https://github.com/OpenBonfire/bonfire/issues/3.
2. **various media kit build errors**: You need `mpv` / `mpv-devel`. Fedora will require you to follow the fix for build issue 1.
3. **symbol lookup error: /lib64/libmpv.so.2: undefined symbol: vkCreateXlibSurfaceKHR** You need to run `export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH` in the same terminal you run bonfire from. This path should correspond to the location that libmpv is stored. I am looking to implement a proper fix for this.

Don't forget to run `dart run build_runner watch -d` before developing! This is required when using freezed and riverpod.

## A quick note for contributors.
We are looking for contributors! I would absolutely love to get this project completed, but it's pretty difficult time-wise. The pacing when I have time to work on it goes pretty fast though, so more people pitching in would be fantastic!