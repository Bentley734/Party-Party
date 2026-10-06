# Party Party 3.1.0 validation

All 16 selected Lua 5.3 headless suites pass. All Lua sources compile and Gen1Recomp 0.3.54 manifest validation passes. The supplied Untamed Advanced beta.7 and 1025Dex 1.2.14 source are used.

- 107,138 current Dex policy assertions, including 20,298 sampled encounters across FR/LG/E and all 17 generation selections. Test both option formats, save/session changes, live League-clear flags, native habitat exceptions, cached header stability and generation refreshes.
- 21,619 species/art assertions cover all 1025 national species, shiny/female palette selection, the native paged atlas, Gen 9 remapping, separate Unown letters, Gimmighoul metadata isolation, two missing-sheet fallbacks and gap pulse rendering dispatch.
- 3,266 native-path assertions exercise actual Untamed private species-generation, spawn and battle functions obtained from its real sandbox-loaded module: 408 land/water cases across FR/LG/E and all choices retain species, level, personality and the exact-battle flag.
- Existing dependency sandbox, six-follower arrival/spacing/collision, menus, saved setting migration, return, jump/mixed/random/wave/social/dance, flowers and pulse-scaling suites pass.

Engine services and graphics calls use headless fixtures. Full GPU rendering and live visual gameplay remain unverified.

Reproduce with Python 3 and lupa (Lua 5.3), extracted gen1recomp-0.3.54, untamed_advanced and 1025Dex folders alongside PartyParty; run `python run_party_party_tests.py`. Obtain image assets from the attached mod ZIP when running species/art tests from a GitHub source archive.
