You can find us on Discord: https://discord.gg/QafRarw25u

# Usage
The fastest way to give it a go is at https://app.openbonfire.dev/! Note that at the time it will most likely require a token to login! This is because everything in the web version is proxied, so Discord requires captcha (which isn't implemented in Bonfire quite yet).

We now offer nightly builds! Please check out the [github actions](https://github.com/OpenBonfire/bonfire/actions) for the latest builds. _You must be logged into to GitHub to view these builds_.

**NOTE**: Bonfire is in it's very early stages of development. It is absolutely NOT ready for regular usage.

# Bonfire
![bonfire graphic frame(2)](https://github.com/user-attachments/assets/ee6ae271-5ad7-4613-a1e8-f4a1f2aaa186)


## About
A modern alternative to the Discord client. Use Discord without ever having to touch the mobile Discord client.

## Platform Support (all are targets, but not all are supported yet)
- 🟩 Android
- 🟥 iOS
- 🟩 Windows
- 🟥 MacOS
- 🟨 Linux 
- 🟨 WearOS (All major android smartwatches)
- 🟨 Web

## Contributor Note
***We are looking for Flutter developers with iOS / macOS devices***. Bonfire can definitely be run on them, but I do not have any to test with, so I cannot add support. MacOS is very close (adding Webview broke the CI, but otherwise runs fine). I have not tested iOS, but there are no major reasons why it should not work. Once the login is revamped to support QR code login, Web and WearOS, and Linux will return as supported.

Because we are using flutter instead of react native, it's possible to cross-compile to platforms other than mobile! The build currently runs on Windows, MacOS, Android, Linux, and now Web! I am unable to test on MacOS and iOS, so consider those builds very experimental.

## General Goals / Ethic
To start, lemmie outline a few things.
- This is not a seperate platform. You login with Discord, you are using all of Discord's features, but through the interface we've made instead of through Discord's.

- **This is against TOS**. Don't do use this unless you have some risk tolerance. *I have never gotten banned in the development of Bonfire, but that isn't to say it can't happen*.

- Our goal here isn't to undermine Discord's monetization- we understand that Discord is a company with bills to pay and employees to feed. Our goal is to create a client that just doesn't suck. It's easy to take a platform like Discord for granted. Yes it has it's problems (I know that more than anyone), but they really have created a cool product, and it's something I'd like to improve as a user.

- Are you a mobile client? Desktop client? Sort of both. Bonfire is a mobile-first client. All of the features we are adding right now are 100% intended for mobile, but because we are using Flutter it's possible to build Bonfire on other platforms. In fact, it currently works just about the same on Windows / MacOS / Linux / Web as it does on mobile (it just needs to be re-themed and re-formatted to look nice).

- Perhaps, extensions? Well yes (in the future). The goal is that Bonfire can be modified to your liking, much like using Vencord and such. It would work very different from a developer standpoint, but having a built-in plugin marketplace would definitely be cool, although yes, quite difficult. It won't be a focus until the client is at a point I'd consider release-ready.

## Why not the BetterDiscord / Vencord Approach?

Mobile is just a different beast due to the difficult nature of modifying packed binaries. While the Desktop client can be fixed relatively easily because it's possible to inject javascript directly into the application, mobile would require modifying the binary ahead of time to patch in your changes. This is extremely difficult due to the locked-down nature of apps (if you'd like to see an example of this approach, check out ReVanced). Instead of trying to hack together patches for an already broken and slow client, we have decided to tackle creating a full re-implementation of the Discord client using the flutter framework!

## Usage Samples - *Note: The app changes fast! These experiences may have improved / changed recently.*
- [Scrolling Demo](https://imgur.com/a/gFivaVV)
- [Channel Switch Demo](https://imgur.com/a/IVhby8W)
- [Messaging / General Usage](https://vimeo.com/958731239?share=copy)

# Developing
## General Info
I'm pretty new to managing public projects, so you'll have to bear with me here. For starters, there's a few projects that OpenBonfire uses and maintains, which can be found in our org. Let's just talk about the big ones.
- [firebridge](https://github.com/OpenBonfire/firebridge): A fork of nyxx (a bot API for Dart) that allows the usage of user tokens. This is very unfinished, and needs a load of work to be done.
- [fireview](https://github.com/OpenBonfire/fireview): A cross-platform webview API that combines multiple webview frameworks. Again, this is not very great and needs a lot of work. This one is a much easier implementation though, I just haven't had the time.

## Progress *not exhaustive, there's a lot of stuff to do*
- 🟨 Login
  - 🟩 WebView-based login
  - 🟨 Web Login (you have to input your token manually)
  - 🟥 WearOS login support (you have to compile yourself with the token hard-coded)

- 🟨 Messaging
  - 🟩 Sending Messages
  - 🟩 Cache Messages
  - 🟨 Message View
  - 🟨 Context Actions (edit, delete, etc)
  - 🟨 Event Actions (edit, delete, etc)
  - 🟨 Embeds
     - 🟩 Youtube embeds
     - 🟩 Tenor videos
     - 🟩 Attachments
        - 🟩 Image Attachments
        - 🟩 Video Attachments
        - 🟩 Audio Attachments (with actual mobile playback)
  - 🟨 Offline Message Scheduling
  - 🟨 Unreads (*viewable but can't be interacted with*)
  - 🟨 Threads (*usable, but barebones*)
  - 🟨 Member List
    - 🟩 Base View
    - 🟩 Networking (handled in firebridge, tricky due to Discord's sharding)
    - 🟥 Member Search
- 🟨 Friends
- 🟨 Guilds
  - 🟩 Guild List
  - 🟩 Guild Networking
  - 🟩 Guild Organization
    - 🟩 Guild Order
    - 🟩 Guild Names
    - 🟩 Guild Folders

**I am set on adding voice / video / etc, but it is very difficult**
- 🟥 Voice Chat
- 🟥 Camera Chat
- 🟥 Screen Sharing

## Building
- Clone Bonfire
- Run `flutter pub run`
- Run `dart run build_runner watch --delete-conflicting-outputs` in a seperate terminal
- You are on your way!

## Build issues (mostly linux)
You may encounter issues on Linux (usually with packaging)
1. **libmpv cannot be found**: Download `libmpv` / `libmpv-devel` (package name varies per distro). If you get an issue in adjacent to `libmpv cannot be found` and it is installed (particuarly on Fedora), run `sudo ln -s /usr/lib64/libmpv.so.2 /usr/lib64/libmpv.so.1`. This issue also appears when running the release varient from GitHub. I will eventually bundle the depend or apply this fix in the library itself. This issue is tracked at https://github.com/OpenBonfire/bonfire/issues/3.
2. **various media kit build errors**: You need `mpv` / `mpv-devel`. Fedora will require you to follow the fix for build issue 1.
3. **symbol lookup error: /lib64/libmpv.so.2: undefined symbol: vkCreateXlibSurfaceKHR** You need to run `export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH` in the same terminal you run bonfire from. This path should correspond to the location that libmpv is stored. I am looking to implement a proper fix for this.

There is also a fun error on Linux that will happen due to the WebView library. Essentially, you will have to handle the libmpv dependency chain yourself. I will automate this in the future, but I don't have a great fix for this at the moment.

Don't forget to run `dart run build_runner watch` before developing! This is required when using freezed and riverpod.

## A quick note for contributors.
We are looking for contributors! I would absolutely love to get this project completed, but it's pretty difficult time-wise. The pacing when I have time to work on it goes pretty fast though, so more people pitching in would be fantastic!

Some of my code might not be great. This is the largest Flutter app I've made by far, so you'll have to bear with me here. Some of the code (looking at you `repositories/messages.dart`) may not be the best. I am absolutely not opposed to full restructuring if it's reasonable, just bring it up with me first.
