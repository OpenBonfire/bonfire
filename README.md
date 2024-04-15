# Bonfire
A modern take on the Discord Client

## About
Full implementation of Discord in Flutter. Uses [Firebridge](https://github.com/Bonfire-Development/firebridge) to communicate with Discord.

# Developing
Don't forget to run `dart run build_runner watch` before starting!

# TODO (temp)
Fix `client.interactions` in firebridge. It currently depends on the user being an application.

Maybe(?) That or I'm using it wrong. I don't know what `interaction_manager` has to do with message read intent.
No, I am using it right. I think it just (needlessly) requires the application to be initialized.

Check `manager_mixin.dart`. You might be able to get away with not initializing the application entirely.

Yes I think that's it. That same file also contains the reference to the channel manager. If you just disable 
application initialization we shold be fine. Long term it might be best to remove application from the 
client all together, let dependents error, then remove the dependents.