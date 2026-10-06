# Party Party 3.1.0
<img width="1254" height="1254" alt="ChatGPT Image Oct 6, 2026, 08_48_39 AM" src="https://github.com/user-attachments/assets/dcbfc94a-7f62-45ee-9a86-a71ca2132606" />

A follower add-on for [Untamed Advanced](https://github.com/goldenroddeptstore/Untamed-Advanced). This is the successor to WildFollowers: Untamed owns the wild encounters, and Party Party extends its party followers.

## Install

1. Use Gen1Recomp 0.3.54 or later in the 0.3 series.
2. Install and enable Untamed Advanced 1.0.0-beta.7 or later compatible 1.x version.
3. Install **PartyParty-v3.1.0.zip** through the mod manager, replacing WildFollowers, then restart.
4. In FireRed, LeafGreen or Emerald, open OPTION → PARTY PARTY. Enable followers in Untamed as well. Open IDLE BEHAVIORS for the idle modes.

The internal mod ID remains `wildfollowers` so installed WildFollowers/Party Parade preferences can migrate. Updates now come from [Bentley734/Party-Party](https://github.com/Bentley734/Party-Party). Install this ZIP once to move to the new update source; keep only one copy installed. Untamed must be enabled; this add-on cannot run by itself. Hoennto and 1025Dex are optional.

## Features

- Choose zero to six healthy party followers.
- Separate trainer and follower spacing, native catch-up movement, dialogue and cries.
- Native Untamed art or G9RP follower sprites, with native fallback for unsupported forms, gender differences and shiny art.
- Idle walking, wandering with speed/range, looking around, jumps and waves, mixed/random behaviors, coordinated dances, zoomies, copycat, sleepy buddy, play tag, cheer, stretch and Doze.
- Safe arrival placement: followers wait for the player, avoid the player's occupied/moving tiles, doorway warp tiles, NPCs and each other, and remain hidden when no legal spot exists.
- Arrival balls and door recalls, flower feet cover, grass animation and recorded follower frames.
- Follower updates behind menus without duplicate normal field ticks.
- Shared follower settings across FireRed, LeafGreen and Emerald, including fresh game option blocks. Settings are saved with the engine options through the normal OPTION/save flow; Hoennto's linked settings sync remains supported.

Party Party has no wild actor pool, encounter engine, spawn controls or wild option page. Configure wild encounters in Untamed Advanced. Old WildFollowers wild-specific preferences are not copied into Untamed.

## 1025Dex compatibility

With 1025Dex enabled, the add-on adapts Untamed's exported services to its live public encounter APIs. The latest supplied 1025Dex 1.2.14 is tested.

- All 1025 national species map to the correct Untamed atlas IDs; Unown letters remain separate from national species 1024/1025. Gen 9 cannot inherit unrelated form/gender metadata.
- Native art/palettes are retained where present. Missing normal Mothim/Floette sheets use the existing G9RP artwork; unsupported shiny gap art keeps Untamed's placeholder.
- Visible grass/water encounters use the Dex generation/terrain/level policy. Native encounter ability and chaining checks can still see the full allowed roster.
- Cached pools refresh for generation choice, save session, League-clear progression and encounter policy revision. Progression-only changes preserve existing wilds; generation/revision changes clear stale generated wilds.
- Field battles keep the visible species, level and personality using the Dex exact-encounter flag, avoiding a second selection roll. Ambient species also use the live policy.

Without 1025Dex, Untamed's native wild pool, tick and encounter/battle policy remain in place. Sprite numbering and gap art fixes still apply.

## Validation

The Lua 5.3 headless suites load the supplied Untamed Advanced beta.7 and this add-on through Gen1Recomp 0.3.54's real mod sandbox. They check dependency failure, unchanged wild services, all follower counts, rendering injection, menu scheduling, both option surfaces, game/new-option migration, safe arrivals, spacing, idle collisions, return routing and idle controllers. A rendering adapter check verifies native paged atlas selection and vertical pulse scaling. Flower clipping tests cover FireRed/LeafGreen and Emerald.

Headless checks pass. Live visual gameplay verification is pending; the test environment mocks engine services and does not run LOVE's actual GPU renderer.

Source is in `PartyParty/` on the repository. Install the attached release ZIP; its G9RP image assets are distributed with the ZIP rather than the GitHub-generated source archives.
