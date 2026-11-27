## [1.0.0] - 2026-11-27

### ⚙️ Miscellaneous Tasks

- Initial commit ([42871a4](https://github.com/copier-templates/shared-dev-tooling/commit/42871a4960150534c15a64bc4146d4222b76e044))
- *(gitignore)* Compose ignore rules from upstream templates ([e8e7b7b](https://github.com/copier-templates/shared-dev-tooling/commit/e8e7b7bae5f6cbad046379f29a3be4e2c93ca033))
- *(editorconfig)* Add cross-language formatting defaults ([0fa45d6](https://github.com/copier-templates/shared-dev-tooling/commit/0fa45d65229e5b79e2fffc4c9f4d6e090af63ed1))
- *(gitattributes)* Normalize line endings and mark binaries ([958c451](https://github.com/copier-templates/shared-dev-tooling/commit/958c45125d8b3e21daff96664dedbe5c27ce9cb7))
- *(prek)* Configure prek hooks with cooldown and priorities ([158091e](https://github.com/copier-templates/shared-dev-tooling/commit/158091e9c1a6a0b915ab8ff2e63b5e88dcb06fcd))
- *(changelog)* Setup git-cliff changelog generation ([a382fa8](https://github.com/copier-templates/shared-dev-tooling/commit/a382fa8ee805d357fbb45ef7c3e2b02095214f66))
- *(mise)* Enforce min release date and lockfile usage, min version ([af3bddf](https://github.com/copier-templates/shared-dev-tooling/commit/af3bddfbc1a46bf230ef6ab8194d7a34e3e9dd8c))
- *(tasks)* Move git-cliff and prek tasks into tasks/ ([c12a8d6](https://github.com/copier-templates/shared-dev-tooling/commit/c12a8d6265d1e282d2c383d73ee6df7d2e069165))
- *(taplo)* Add taplo to autoformat TOML configuration ([5afd124](https://github.com/copier-templates/shared-dev-tooling/commit/5afd124b96245f4d7b4521f8f3ba5f5cb0702608))
- *(toml)* Format TOML configuration with taplo ([5e21ea5](https://github.com/copier-templates/shared-dev-tooling/commit/5e21ea52249605f69c80f3410900858c120f546f))
- *(prek)* Label hook names by source ([267ca8b](https://github.com/copier-templates/shared-dev-tooling/commit/267ca8b712dcbb7ff39fbc4a21fb45b69fc84c74))
- *(python)* Add python tasks covering uv,ruff,ty etc. ([5d60bcd](https://github.com/copier-templates/shared-dev-tooling/commit/5d60bcd8befdc227c16eb035c90c99af2a8381f7))
- *(gh)* Add tasks to lint Github Actions ([3910798](https://github.com/copier-templates/shared-dev-tooling/commit/39107989c9a5992e144220bd74a9676f8de1d0ac))
- *(tags)* Add mise:tags task to list all existing tags ([3fcfe24](https://github.com/copier-templates/shared-dev-tooling/commit/3fcfe242142dd4f041370405ae92fc859144a9e2))
- *(bun)* Add bun to mise ([c5cfaf9](https://github.com/copier-templates/shared-dev-tooling/commit/c5cfaf90e97f6166bab4fa09d43928782dac6e62))
- *(mise)* Add shared git defaults via enter hook ([03db9c9](https://github.com/copier-templates/shared-dev-tooling/commit/03db9c97c5bd7bcbf052c850527c3590ae9befd6))
- *(git)* Move github actions under tasks/cicd folder ([e08385f](https://github.com/copier-templates/shared-dev-tooling/commit/e08385fe6fce23e2e341012c7125218d9ef2787e))
- *(prek)* Audit config to current patterns ([c2812f5](https://github.com/copier-templates/shared-dev-tooling/commit/c2812f50e523b55ba8556b8e563ebd0c60bc68a7))

### 📚 Documentation

- *(readme)* Describe shared task scope and usage ([2520acd](https://github.com/copier-templates/shared-dev-tooling/commit/2520acd626115638a91f95c697594f185b58356f))
- Add AGENTS.md and mise/prek guidelines, update README ([c37397a](https://github.com/copier-templates/shared-dev-tooling/commit/c37397ae466979c40a0705e0ab97efcd0e4bff75))
- Explain how consumers reuse hooks via the manifest ([40a650d](https://github.com/copier-templates/shared-dev-tooling/commit/40a650daab0a6a159c7c3eff25b380f32d9f8918))
- Move guidelines under docs/guidelines ([0c492ae](https://github.com/copier-templates/shared-dev-tooling/commit/0c492aecff6117aec5e68dbe734e23583d62fc4b))
- *(glossary)* Define core shared-dev-tooling terms ([4685ba3](https://github.com/copier-templates/shared-dev-tooling/commit/4685ba31a23082ca8d82085cc285ac2013e91eb4))
- *(guidelines)* Update guidelines and shell coding standards, add gum guidlines ([c0f058c](https://github.com/copier-templates/shared-dev-tooling/commit/c0f058cf3157d8e2c2fd2718670bb0ff8d2ec4d2))
- Update tag taxonomy and grouping rules ([8b69180](https://github.com/copier-templates/shared-dev-tooling/commit/8b69180851986c11e002d1db4599519569ff64e6))
- *(readme)* Add stack and docs status badges ([4bb6c13](https://github.com/copier-templates/shared-dev-tooling/commit/4bb6c1393e310edffdd911254983a5309c357c62))
- Modernize README and Starlight site ([b5f8f1d](https://github.com/copier-templates/shared-dev-tooling/commit/b5f8f1d4698f157b42f8e86ffc1f71c9b5fdceae))

### 🚀 Features

- *(hooks)* Add prek install and run tasks ([f82c9b3](https://github.com/copier-templates/shared-dev-tooling/commit/f82c9b36fd041984f6fc2a00200c0db3f80fcef1))
- *(prek)* Check mise.lock consistency ([1937308](https://github.com/copier-templates/shared-dev-tooling/commit/1937308bab220b6aa96996deb7cfc5fc70da5537))
- *(mise)* Add maintenance task group ([44eb87d](https://github.com/copier-templates/shared-dev-tooling/commit/44eb87d3427c4fe27daa5b359d77636e7b88825b))
- *(prek)* Validate mise tasks ([27d676d](https://github.com/copier-templates/shared-dev-tooling/commit/27d676db0eded5fb276db92ffd4101e65dd47b62))
- *(tasks)* [**breaking**] Name tasks <tool>:<verb> and tag them by purpose ([d1ce751](https://github.com/copier-templates/shared-dev-tooling/commit/d1ce751d308630c1f57c50b65bb692d3d40e9457))
- *(prek)* Publish hook manifest wrapping shared mise tasks ([109be91](https://github.com/copier-templates/shared-dev-tooling/commit/109be91ff07184fa391f810a785283c354b8ed86))
- *(tooling)* Add shell lint hooks and release:cut task ([bce3b81](https://github.com/copier-templates/shared-dev-tooling/commit/bce3b8197fadd6e9a051c5c9c4e3ff8d7e2504d1))
- Add prek Github action workflow ([f491f55](https://github.com/copier-templates/shared-dev-tooling/commit/f491f55e15afd5dc502a0bd0e22686436575dfaa))
- *(bun)* Add install, update, test, and clean tasks ([5f04978](https://github.com/copier-templates/shared-dev-tooling/commit/5f049781aa2c0d204ea6eb892bfd9b31a8a402b9))
- *(docs)* Add Starlight docs site with Pages deploy ([671e93d](https://github.com/copier-templates/shared-dev-tooling/commit/671e93dece541fe0c45145cc3dda383e22260e12))
- *(core)* Add tag gates and tighten mise/prek tasks ([65fb314](https://github.com/copier-templates/shared-dev-tooling/commit/65fb31446b8cae6dfa1d60aed54aa8d45d78b2d2))
- *(bun)* Use skip_if, raw_args, sources and lifecycle tags ([b7ffc33](https://github.com/copier-templates/shared-dev-tooling/commit/b7ffc33beec5208d427eef5a2fd5ff98cc42eb8d))
- *(cicd)* Rename to github.tasks.toml, fix discovery, add update checks ([fe41e7f](https://github.com/copier-templates/shared-dev-tooling/commit/fe41e7f48c5e9f77871e48f47c158c6bb91024f1))
- *(docs)* Use lifecycle tags, interactive, confirm and optional deps ([7b9e072](https://github.com/copier-templates/shared-dev-tooling/commit/7b9e072153bcdcb98f040ce48049828785f3776a))
- *(py)* Use skip_if, raw_args, locks and lifecycle tags ([4363ecf](https://github.com/copier-templates/shared-dev-tooling/commit/4363ecf178c24fc99b0d63013bae86af622bb5c1))
- *(release)* Fix v-tags, untracked changelog and git-cliff naming ([05e1b8f](https://github.com/copier-templates/shared-dev-tooling/commit/05e1b8f5f2eb49bfdc7ca28522c750ff4de5574e))
- *(sh,toml)* Skip empty file lists, add fmt checks and sources ([49eec49](https://github.com/copier-templates/shared-dev-tooling/commit/49eec49af56b4a242ece96856469473cec281c8b))
- *(release)* Link changelog entries to commits ([5c8c450](https://github.com/copier-templates/shared-dev-tooling/commit/5c8c450409ec6f00fb611e901b897ef7c729c0fe))
- *(core)* Group tag gates under gate: prefix with bare aliases ([25cdc87](https://github.com/copier-templates/shared-dev-tooling/commit/25cdc8797806d558951e73ac502699aa60d0b31b))
- *(core,bun,py)* Quiet setup tasks by default with --verbose override ([31c0da2](https://github.com/copier-templates/shared-dev-tooling/commit/31c0da2af6b74ba0267d1b60c55f5cf577adc1d2))
- *(gates)* Add clean gate, wire fix through fmt ([48f5e15](https://github.com/copier-templates/shared-dev-tooling/commit/48f5e15b32406f326eb725aa2d4024295e44d649))
- *(docs)* Add themed light/dark logo to README and site ([d36af33](https://github.com/copier-templates/shared-dev-tooling/commit/d36af33b836443a1ad4de29f6b8728a1619f1987))
- *(release)* Publish GitHub Release from release:cut ([4438f9b](https://github.com/copier-templates/shared-dev-tooling/commit/4438f9b1aa71e909db47de58158b3f727050107e))

### 🐛 Bug Fixes

- *(prek)* Run taplo hooks via repo-pinned binary ([6d1e60e](https://github.com/copier-templates/shared-dev-tooling/commit/6d1e60eba6f460fa0576f274711b46465a315f75))
- *(prek)* Align local hook file filters with the published manifest ([b39cb8a](https://github.com/copier-templates/shared-dev-tooling/commit/b39cb8a73febf2c36a090c25c7494249dcf9aaf3))
- *(tasks)* Limit mise:outdated to project tools ([8a87601](https://github.com/copier-templates/shared-dev-tooling/commit/8a87601d4c21055fc11195de706c27c70108b548))
- *(changelog)* Skip release commits and keep parser order ([58e9114](https://github.com/copier-templates/shared-dev-tooling/commit/58e91142923d47156ce119d1a256c900e5f1ac73))
- *(gh)* Pin workflow actions to commit SHAs ([c675ca4](https://github.com/copier-templates/shared-dev-tooling/commit/c675ca4f08e99bb114e58eb43932b273a57c26d5))
- *(toml)* Validate task files with mise tasks validate, not taplo ([b3d925a](https://github.com/copier-templates/shared-dev-tooling/commit/b3d925aad142fc72f152acbf022ce35721e91f8d))
- *(gates)* Run gate:all in order with parallel checks ([5f869bc](https://github.com/copier-templates/shared-dev-tooling/commit/5f869bcabcca10961d039d5a8ed99c173d7b9644))
- *(taplo)* Silence info logs by default ([0d7056b](https://github.com/copier-templates/shared-dev-tooling/commit/0d7056bfcfa8b66265aa884a0110ed5d86c3523b))
- *(release)* Only gate release:cut on behind, warn on ahead ([549a318](https://github.com/copier-templates/shared-dev-tooling/commit/549a31892d2442020447f730f34b1b2c7210dcc6))
- *(docs)* Strip source H1 during sync to avoid duplicate titles ([035dac9](https://github.com/copier-templates/shared-dev-tooling/commit/035dac97211eba787b6c1b4787d5ee0f51c1fa16))
- *(docs)* Center Starlight page title to match hero ([57267a3](https://github.com/copier-templates/shared-dev-tooling/commit/57267a39d5f36a0b81c8bf02346e1cdf8d458923))
- *(docs)* Resolve internal .md links to directory routes and check them ([622e059](https://github.com/copier-templates/shared-dev-tooling/commit/622e059466b6c68fbf50364ffa10753bf1b4249f))
- *(ts)* Exclude node_modules from type-checking ([0a4d821](https://github.com/copier-templates/shared-dev-tooling/commit/0a4d8213e0466ea91665646b7b1efc4866d08f36))
- *(docs)* Quote Starlight title in generated frontmatter ([40ce154](https://github.com/copier-templates/shared-dev-tooling/commit/40ce154cfb3cf25c9bf96d89f9370c3663e79b80))
- *(docs)* Use depth-aware logo path in docs sync ([a4055e7](https://github.com/copier-templates/shared-dev-tooling/commit/a4055e749a50c1c16ea3b6086f90e8c0dfac5a4a))
- *(docs)* Check absolute links and image sources ([bc92273](https://github.com/copier-templates/shared-dev-tooling/commit/bc9227346e758828ffec3157d9c2a620d7d3a412))
- *(ci)* Lint composite actions and fix find precedence ([e10a93a](https://github.com/copier-templates/shared-dev-tooling/commit/e10a93aec407bba26a4d9a8ae25911023bfb56c7))
- *(release)* Handle empty remote, cancel, and odd tags in cut ([fde187c](https://github.com/copier-templates/shared-dev-tooling/commit/fde187cbe724578685e9b18750c73aeb264af1ab))
- *(py)* Make uv:sync:check a pure lint gate ([436a0ee](https://github.com/copier-templates/shared-dev-tooling/commit/436a0ee213994b4dfd0c01134d02ddc3d521b489))
- *(release)* Check origin for exact tag collision ([6876eb3](https://github.com/copier-templates/shared-dev-tooling/commit/6876eb3b52459a8b2ea096f8d945b69f818301ca))
- *(release)* Avoid atomic push on non-GitHub remotes ([3b4a9e4](https://github.com/copier-templates/shared-dev-tooling/commit/3b4a9e44e12b35046186378bc12284da9d6aad09))
- *(docs)* Only create Pages site on 404 ([5e8eed9](https://github.com/copier-templates/shared-dev-tooling/commit/5e8eed9326437c280d62c30b47ec07e6e0f9fa5b))
- *(mise)* Parse task tags as JSON ([ac6bd98](https://github.com/copier-templates/shared-dev-tooling/commit/ac6bd983d3c50d1c42be25884c4509e53ec5a47a))
- *(a11y)* Prevent theme listener leak on client navigation ([59700ae](https://github.com/copier-templates/shared-dev-tooling/commit/59700ae2175951035b40e9308186441524c777ec))
- *(prek)* Drop stale version-tag gate from comments ([fb83314](https://github.com/copier-templates/shared-dev-tooling/commit/fb83314acb4dbeb2eba9182ab420d9a86446c5b9))
- *(release)* Surface fetch errors instead of failing silently ([3d52b4d](https://github.com/copier-templates/shared-dev-tooling/commit/3d52b4d53ecd53c0bdcf86085b80d58f5857024d))

### 🚜 Refactor

- *(tasks)* Group task files into category subfolders ([9a7a469](https://github.com/copier-templates/shared-dev-tooling/commit/9a7a469436c03f562c4fbe0ffa93c4461782f5db))
- *(prek)* Run local hooks through shared mise tasks ([bb182c7](https://github.com/copier-templates/shared-dev-tooling/commit/bb182c714d0e562ad269a6dc586fa3ada56cea17))
- *(tasks)* Name task files <tool>.tasks.toml ([495bed1](https://github.com/copier-templates/shared-dev-tooling/commit/495bed1ae86f5bad052e1a0c145568cdefa243e3))
- *(shell)* Consolidate shfmt naming, drop duplicate formatter ([b4abd02](https://github.com/copier-templates/shared-dev-tooling/commit/b4abd02c1f0efed94cb6745d3ad319ff28ab1cc7))
- *(deps)* Standardize update verb, drop orphan check tag ([a0a4d2f](https://github.com/copier-templates/shared-dev-tooling/commit/a0a4d2f54770cf791e32922b17b8c5dda5edce61))
- *(cicd)* Rename gh:lint to gh:workflows:lint ([7a3652f](https://github.com/copier-templates/shared-dev-tooling/commit/7a3652ff58ea058444e0b5a37160cd8068595527))
- *(docs)* Merge ops into release, isolate changelog tag ([f59385d](https://github.com/copier-templates/shared-dev-tooling/commit/f59385d1cd6a62eb05d27ab00bde95a31b3b3244))

### 🧪 Testing

- *(bun)* Add dummy smoke test so bun:test passes ([135acc5](https://github.com/copier-templates/shared-dev-tooling/commit/135acc5e0cad8856f6f06ed0d3a35808ef9c93fb))

### 💼 Other

- *(docs)* Add Node, gh, and Astro toolchain ([b4971b1](https://github.com/copier-templates/shared-dev-tooling/commit/b4971b1843ab1edb460501ae238100c305b2c5b2))
