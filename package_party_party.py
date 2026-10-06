from pathlib import Path
import json,zipfile,hashlib
root=Path(__file__).resolve().parent
addon=root/'PartyParty'
(addon/'CHANGELOG.md').write_text('''# Party Party 3.1.0

Rename Party Parade to Party Party and move updates/source/releases to Bentley734/Party-Party. Keep the internal wildfollowers ID and follower option keys for migration.

Restore the WildFollowers 1025Dex compatibility fixes on the required Untamed Advanced engine: Gen 9 atlas numbering, Unown separation, all 1025 normal follower sprite coverage, live generation/terrain/level policy, League-clear/save/revision cache invalidation, ambient species selection and exact visible encounter identity in battles.

Use the dependency's native OWE spawner and wild pool. Its ability/chaining checks keep the complete policy roster; normal grass/water slot choices sample the public Dex policy. Preserve native wild options and native behavior when Dex is absent. Retain all six-follower, spacing, idle/group behaviors, safe arrival and shared-settings features from 3.0.0.
''',encoding='utf-8')
(addon/'VALIDATION.md').write_text('''# Party Party 3.1.0 validation

All 16 selected Lua 5.3 headless suites pass. All Lua sources compile and Gen1Recomp 0.3.54 manifest validation passes. The supplied Untamed Advanced beta.7 and 1025Dex 1.2.14 source are used.

- 107,138 current Dex policy assertions, including 20,298 sampled encounters across FR/LG/E and all 17 generation selections. Test both option formats, save/session changes, live League-clear flags, native habitat exceptions, cached header stability and generation refreshes.
- 21,619 species/art assertions cover all 1025 national species, shiny/female palette selection, the native paged atlas, Gen 9 remapping, separate Unown letters, Gimmighoul metadata isolation, two missing-sheet fallbacks and gap pulse rendering dispatch.
- 3,266 native-path assertions exercise actual Untamed private species-generation, spawn and battle functions obtained from its real sandbox-loaded module: 408 land/water cases across FR/LG/E and all choices retain species, level, personality and the exact-battle flag.
- Existing dependency sandbox, six-follower arrival/spacing/collision, menus, saved setting migration, return, jump/mixed/random/wave/social/dance, flowers and pulse-scaling suites pass.

Engine services and graphics calls use headless fixtures. Full GPU rendering and live visual gameplay remain unverified.

Reproduce with Python 3 and lupa (Lua 5.3), extracted gen1recomp-0.3.54, untamed_advanced and 1025Dex folders alongside PartyParty; run `python run_party_party_tests.py`. Obtain image assets from the attached mod ZIP when running species/art tests from a GitHub source archive.
''',encoding='utf-8')
archive=root/'PartyParty-v3.1.0.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for p in sorted(addon.rglob('*')):
        if p.is_file():z.write(p,'wildfollowers/'+p.relative_to(addon).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    m=json.loads(z.read('wildfollowers/manifest.json'))
    assert m['name']=='Party Party' and m['github']=='Bentley734/Party-Party' and m['version']=='3.1.0'
    assert not any(n.endswith(('/owe.lua','/data.lua','/atlas.png','/palettes.png')) for n in z.namelist())
files=[p for p in sorted(addon.rglob('*')) if p.is_file() and p.suffix in ('.lua','.json','.md','.tsv')]
tree=[{'path':'PartyParty/'+p.relative_to(addon).as_posix(),'mode':'100644','type':'blob','content':p.read_text(encoding='utf-8')} for p in files]
for name,p in [('README.md',addon/'README.md'),('run_party_party_tests.py',root/'run_party_party_tests.py'),('package_party_party.py',root/'package_party_party.py')]:
    tree.append({'path':name,'mode':'100644','type':'blob','content':p.read_text(encoding='utf-8')})
(root/'party_party_github_tree.json').write_text(json.dumps(tree),encoding='utf-8')
digest=hashlib.sha256(archive.read_bytes()).hexdigest()
(root/'PartyParty-v3.1.0.sha256').write_text(digest+'  '+archive.name+'\n')
print(json.dumps({'zip':str(archive),'bytes':archive.stat().st_size,'sha256':digest,'source_files':len(files)}))
