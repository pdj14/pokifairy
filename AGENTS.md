# Repository Guidelines

## Project Structure & Module Organization
PokiFairy starts intentionally empty so contributors can layer systems incrementally. Create a `src/` directory for gameplay logic in modular TypeScript files; isolate feature verticals (e.g., `src/world`, `src/ui`). Keep tests under `tests/` mirroring module names (`tests/world/Teleport.test.ts`). Store art, audio, and data in `assets/` with subfolders by asset type. Helper scripts and one-off migrations belong in `tools/`. Document broader design decisions in `docs/` and link diagrams or product notes from there.

## Build, Test, and Development Commands
Add reusable commands to `package.json` (or `Makefile`) so the team shares a single entry point. Standard commands we expect:
- `npm install` to restore dependencies.
- `npm run dev` to launch the hot-reload playground.
- `npm run build` to produce a production bundle in `dist/`.
- `npm test` (optionally with `--watch`) for automated suites.
Keep any engine-specific CLI flags inside the script definition instead of ad-hoc shell notes.

## Coding Style & Naming Conventions
Default to TypeScript with strict mode enabled; favor ES modules and 2-space indentation. Name files using kebab-case (`level-loader.ts`), classes in PascalCase, and functions/variables in camelCase. Export a single public surface per module. Run `npm run lint` (configure ESLint + Prettier) before pushing; prefer declarative commits over inline suppression comments. Co-locate SCSS or JSON configs next to the module they support.

## Testing Guidelines
Use Vitest or Jest for unit coverage; prefer Playwright for interaction tests once UI is available. Name files `*.test.ts` and keep fixtures in `tests/fixtures`. Target >=80% statement coverage; include regression tests for every bugfix with a brief comment linking the issue ID. Integration tests that hit external APIs should be wrapped with mocks so CI remains deterministic.

## Commit & Pull Request Guidelines
Follow Conventional Commits (`feat:`, `fix:`, `chore:`) with imperative, present-tense summaries under 72 characters. Reference ticket IDs in the body when applicable. Pull requests must include: a concise summary, testing notes (`npm test`, `npm run build`), and screenshots or GIFs for UI changes. Request review from at least one maintainer, and ensure draft PRs stay in draft until all checks pass and TODOs are resolved.
