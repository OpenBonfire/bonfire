# Bonfire
A modern take on the Discord Client

## About
Full implementation of Discord in Flutter. Uses [Firebridge](https://github.com/Bonfire-Development/firebridge) to communicate with Discord.

# Developing
Don't forget to run `dart run build_runner watch` before developing! This is required when using freezed and riverpod.

# TODO (temp)
Don't have a username / password in the authuser object
Instead the auth provider should only be used for login
then you navigate with a non-nullable AuthUser object