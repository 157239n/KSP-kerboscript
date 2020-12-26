# KSP-kerboscript

These are KOS automated scripts in Kerbal Space Program. There are a few of them:
- haul.ks: hauls the rocket so that it's in a velocity range and a height range.
- orbit.ks: goes to orbit.
- suicide.ks: does a suicide burn. Can't handle too much lateral velocity though, so be careful.
- changeorbit.ks: changes the current orbit to another one with specified periapsis and apoapsis. Ship's reaction wheels can move slowly.
- rendezvous.ks: rendezvous with a specified target. Expected to be close enough (within 10km) and relative velocity less than 400m/s to actually work. Ship's reaction wheels must move the ship fast. After this, relative position will be less than 50m and relative velocity is effectively 0m/s.
- encounter.ks: for complex docking, then it is expected that you do it on your own after executing rendezvous.ks. But for simple docking, then this will point towards the target, nudge a bit, and keep track of the target until it actually docks.
- stats.ks: a few useful stats.
