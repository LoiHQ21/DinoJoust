# Push this handoff to GitHub

1. Extract `Jurassic_Joust_Crownfall_GitHub_Starter.zip` to a folder, for example `jurassic-joust-crownfall`.
2. Review `README.md`, `AGENTS.md`, and `docs/design/DECISIONS.md` before inviting an agent to change code.
3. In a terminal inside the extracted folder:

```sh
git init
git add .
git commit -m "docs: import Crownfall design handoff and concepts"
git branch -M main
```

4. Create an **empty repository** on GitHub (e.g. `jurassic-joust-crownfall`) without auto-generating a README.
5. Add your repository URL and push:

```sh
git remote add origin https://github.com/YOUR_ACCOUNT/jurassic-joust-crownfall.git
git push -u origin main
```

6. Start Codex in the repository and use `docs/prompts/CODEX_FIRST_TASK.md` to request the first vertical slice.

If GitHub rejects a large binary later, configure Git LFS for new assets; do not duplicate entire reference archives in game export bundles. Check legal permission and any platform rules before making asset references public. Keep third-party reference screenshots out of the repository by default.

**Important:** this ZIP is a Git-ready directory, not an already initialized Git repository, and it does not contain a playable engine project.
